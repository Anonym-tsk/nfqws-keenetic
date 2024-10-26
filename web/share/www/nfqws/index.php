<?php

ini_set('memory_limit', '32M');

function normalizeString(string $s): string {
    // Convert all line-endings to UNIX format.
    $s = str_replace(array("\r\n", "\r", "\n"), "\n", $s);

    // Don't allow out-of-control blank lines.
    $s = preg_replace("/\n{3,}/", "\n\n", $s);

    $lastChar = substr($s, -1);
    if ($lastChar !== "\n") {
        $s .= "\n";
    }

    return $s;
}

function getFiles($path = '/opt/etc/nfqws'): array {
    $files = array_filter(glob($path . '/*.{list,list-opkg,list-old,conf,conf-opkg,conf-old}', GLOB_BRACE), 'is_file');
    $logfile = '/opt/var/log/nfqws.log';
    $basenames = array_map(fn($file) => basename($file), $files);
    if (file_exists($logfile)) {
        array_push($basenames, basename($logfile));
    }

    $priority = ['nfqws.conf' => -5, 'user.list' => -4, 'exclude.list' => -3, 'auto.list' => -2, 'nfqws.log' => -1];
    usort($basenames, fn($a, $b) => ($priority[$a] ?? 1) - ($priority[$b] ?? -1));

    return $basenames;
}

function getFileContent(string $filename, $path = '/opt/etc/nfqws'): string {
    return file_get_contents($path . '/' . basename($filename));
}

function getLogContent(string $filename, $path = '/opt/var/log'): string {
    $file = file($path . '/' . basename($filename));
    $file = array_reverse($file);
    return implode("", $file);
}

function saveFile(string $filename, string $content, $path = '/opt/etc/nfqws') {
    $filename = basename($filename);
    $file = $path . '/' . $filename;
    if (file_exists($file)) {
        return file_put_contents($file, normalizeString($content));
    } else {
        return false;
    }
}

function removeFile(string $filename, $path = '/opt/etc/nfqws') {
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
    exec('/opt/etc/init.d/S51nfqws status', $output);
    return str_contains($output[0] ?? '', 'is running');
}

function nfqwsServiceAction(string $action) {
    $output = null;
    $retval = null;
    exec("/opt/etc/init.d/S51nfqws $action", $output, $retval);
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
    $passwdFile = '/opt/etc/passwd';
    $shadowFile = '/opt/etc/shadow';

    $users = file(file_exists($shadowFile) ? $shadowFile : $passwdFile);
    $user = preg_grep("/^$username/", $users);

    if ($user) {
        list(, $passwdInDB) = explode(':', array_pop($user));
        if (crypt($password, $passwdInDB) == $passwdInDB) {
            return true;
        }
    }

    return false;
}

function opkgUpdate() {
    $output = null;
    $retval = null;
    exec('opkg update', $output, $retval);
    return array('output' => $output, 'status' => $retval);
}

function opkgUpgrade() {
    $code = <<<'CODE'
<?php
$output = null;
$retval = null;
exec('opkg upgrade nfqws-keenetic nfqws-keenetic-web', $output, $retval);
if (empty($output)) {
    $output[] = 'Nothing to upgrade';
}
$response = array('output' => $output, 'status' => $retval);
header('Content-Type: application/json; charset=utf-8');
http_response_code(200);
echo json_encode($response);
unlink('/opt/share/www/nfqws/opkg.php');
exit();
CODE;

    $file = fopen('/opt/share/www/nfqws/opkg.php', 'w');
    fwrite($file, $code);
    fclose($file);

    http_response_code(302);
    header('Location: opkg.php');
    exit();
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
            $response = opkgUpdate();
            break;

        case 'upgrade':
            opkgUpgrade();
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
