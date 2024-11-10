<?php

ini_set('memory_limit', '32M');

define('ROOT_DIR', file_exists('/opt/etc/nfqws/nfqws.conf') ? '/opt' : '');
define('SCRIPT_NAME', ROOT_DIR ? 'S51nfqws' : 'nfqws-keenetic');

function normalizeString(string $s): string {
    // Convert all line-endings to UNIX format.
    $s = str_replace(array("\r\n", "\r", "\n"), "\n", $s);

    // Don't allow out-of-control blank lines.
    $s = preg_replace("/\n{3,}/", "\n\n", $s);

    $lastChar = substr($s, -1);
    if ($lastChar !== "\n" && !empty($s)) {
        $s .= "\n";
    }

    return $s;
}

function getFiles($path = ROOT_DIR . '/etc/nfqws'): array {
    // GLOB_BRACE is unsupported in openwrt
    $files = array_filter(glob($path . '/*'), function ($file) {
        return is_file($file) && preg_match('/\.(list|list-opkg|list-old|conf|conf-opkg|conf-old)$/i', $file);
    });
    $logfile = ROOT_DIR . '/var/log/nfqws.log';
    $basenames = array_map(fn($file) => basename($file), $files);
    if (file_exists($logfile)) {
        array_push($basenames, basename($logfile));
    }

    $priority = ['nfqws.conf' => -5, 'user.list' => -4, 'exclude.list' => -3, 'auto.list' => -2, 'nfqws.log' => -1];
    usort($basenames, fn($a, $b) => ($priority[$a] ?? 1) - ($priority[$b] ?? -1));

    return $basenames;
}

function getFileContent(string $filename, $path = ROOT_DIR . '/etc/nfqws'): string {
    return file_get_contents($path . '/' . basename($filename));
}

function getLogContent(string $filename, $path = ROOT_DIR . '/var/log'): string {
    $file = file($path . '/' . basename($filename));
    $file = array_reverse($file);
    return implode("", $file);
}

function saveFile(string $filename, string $content, $path = ROOT_DIR . '/etc/nfqws') {
    $filename = basename($filename);
    $file = $path . '/' . $filename;
    if (file_exists($file)) {
        if (file_put_contents($file, normalizeString($content)) !== false) {
            return true;
        }
        return false;
    } else {
        return false;
    }
}

function removeFile(string $filename, $path = ROOT_DIR . '/etc/nfqws') {
    $filename = basename($filename);
    $file = $path . '/' . $filename;
    if (file_exists($file)) {
        return unlink($file);
    } else {
        return false;
    }
}

function nfqwsServiceStatus() {
    $output = null;
    exec(ROOT_DIR . "/etc/init.d/" . SCRIPT_NAME . " status", $output);
    return str_contains($output[0] ?? '', 'is running');
}

function nfqwsServiceAction(string $action) {
    $output = null;
    $retval = null;
    exec(ROOT_DIR . "/etc/init.d/" . SCRIPT_NAME . " $action", $output, $retval);
    return array('output' => $output, 'status' => $retval);
}

function opkgAction(string $action) {
    $output = null;
    $retval = null;
    exec("opkg $action", $output, $retval);
    if (empty($output)) {
        $output[] = 'Nothing to upgrade';
    }
    return array('output' => $output, 'status' => $retval);
}

function authenticate($username, $password) {
    $passwdFile = ROOT_DIR . '/etc/passwd';
    $shadowFile = ROOT_DIR . '/etc/shadow';

    $users = file(file_exists($shadowFile) ? $shadowFile : $passwdFile);
    $user = preg_grep("/^$username/", $users);

    if ($user) {
        list(, $passwdInDB) = explode(':', array_pop($user));
        if (empty($passwdInDB)) {
            return empty($password);
        }
        if (crypt($password, $passwdInDB) == $passwdInDB) {
            return true;
        }
    }

    return false;
}

function main() {
    if (!isset($_SERVER['REQUEST_METHOD']) || $_SERVER['REQUEST_METHOD'] !== 'POST') {
        http_response_code(302);
        header('Location: index.html');
        exit();
    }

    session_start();
    if (!isset($_SESSION['auth']) || !$_SESSION['auth']) {
        if ($_POST['cmd'] !== 'login' || !isset($_POST['user']) || !isset($_POST['password']) || !authenticate($_POST['user'], $_POST['password'])) {
            http_response_code(401);
            exit();
        } else {
            $_SESSION['auth'] = true;
        }
    }

    switch ($_POST['cmd']) {
        case 'filenames':
            $files = getFiles();
            $response = array('status' => 0, 'files' => $files, 'service' => nfqwsServiceStatus());
            break;

        case 'filecontent':
            if (str_ends_with($_POST['filename'], '.log')) {
                $content = getLogContent($_POST['filename']);
            } else {
                $content = getFileContent($_POST['filename']);
            }
            $response = array('status' => 0, 'content' => $content, 'filename' => $_POST['filename']);
            break;

        case 'filesave':
            $result = saveFile($_POST['filename'], $_POST['content']);
            $response = array('status' => $result ? 0 : 1, 'filename' => $_POST['filename']);
            break;

        case 'fileremove':
            $result = removeFile($_POST['filename']);
            $response = array('status' => $result ? 0 : 1, 'filename' => $_POST['filename']);
            break;

        case 'reload':
        case 'restart':
        case 'stop':
        case 'start':
            $response = nfqwsServiceAction($_POST['cmd']);
            break;

        case 'update':
            $response = opkgAction('update');
            break;

        case 'upgrade':
            $response = opkgAction('upgrade nfqws-keenetic nfqws-keenetic-web');
            break;

        case 'login':
            $response = array('status' => 0);
            break;

        case 'logout':
            $_SESSION['auth'] = false;
            $response = array('status' => 0);
            break;

        default:
            http_response_code(405);
            exit();
    }

    header('Content-Type: application/json; charset=utf-8');
    http_response_code(200);
    echo json_encode($response);
    exit();
}

main();
