<?php

ini_set('memory_limit', '32M');

function normalizeString(string $s): string {
    // Convert all line-endings to UNIX format.
    $s = str_replace(array("\r\n", "\r", "\n"), "\n", $s);

    // Don't allow out-of-control blank lines.
    $s = preg_replace("/\n{3,}/", "\n\n", $s);
    return $s . "\n";
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
    return implode("\n", $file);
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

function authenticate($username, $password) {
    $passwdFile = '/opt/etc/passwd';
    $users = file($passwdFile);
    $user = preg_grep("/^$username/", $users);

    if ($user) {
        list(, $passwdInDB) = explode(':', array_pop($user));
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

    if (!isset($_SERVER['PHP_AUTH_USER']) || !isset($_SERVER['PHP_AUTH_PW']) || !authenticate($_SERVER['PHP_AUTH_USER'], $_SERVER['PHP_AUTH_PW'])) {
        header('WWW-Authenticate: Basic realm="nfqws-keenetic"');
        header('HTTP/1.0 401 Unauthorized');
        exit();
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
