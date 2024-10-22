<?php

function normalizeString(string $s): string {
    // Convert all line-endings to UNIX format.
    $s = str_replace(array("\r\n", "\r", "\n"), "\n", $s);

    // Don't allow out-of-control blank lines.
    $s = preg_replace("/\n{3,}/", "\n\n", $s);
    return $s . "\n";
}

function createToken(): string {
    $file = realpath(dirname(__FILE__)) . DIRECTORY_SEPARATOR . basename(__FILE__);
    return sha1_file($file) ?? 'nothing';
}

function getFiles($path = '/opt/etc/nfqws'): array {
    $files = array_filter(glob($path . '/*.{list,list-opkg,list-old,conf,conf-opkg,conf-old}', GLOB_BRACE), 'is_file');
    $basenames = array_map(fn($file) => basename($file), $files);

    $priority = ['nfqws.conf' => -4, 'user.list' => -3, 'exclude.list' => -2, 'auto.list' => -1];
    usort($basenames, fn($a, $b) => ($priority[$a] ?? 1) - ($priority[$b] ?? -1));

    return $basenames;
}

function getFileContent(string $filename, $path = '/opt/etc/nfqws'): string {
    return file_get_contents($path . '/' . basename($filename));
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

function reloadNfqws() {
    $output = null;
    $retval = null;
    exec('/opt/etc/init.d/S51nfqws reload', $output, $retval);
    return array('output' => $output, 'status' => $retval);
}

function restartNfqws() {
    $output = null;
    $retval = null;
    exec('/opt/etc/init.d/S51nfqws restart', $output, $retval);
    return array('output' => $output, 'status' => $retval);
}

function main() {
    if (isset($_SERVER['REQUEST_METHOD']) && $_SERVER['REQUEST_METHOD'] === 'POST') {
        if ($_POST['cmd'] !== 'filenames') {
            if (!$_POST['token'] || $_POST['token'] !== createToken()) {
                http_response_code(403);
                exit();
            }
        }

        switch ($_POST['cmd']) {
            case 'filenames':
                $files = getFiles();
                $response = array('status' => 0, 'files' => $files, 'token' => createToken());
                break;

            case 'filecontent':
                $content = getFileContent($_POST['filename']);
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
                $response = reloadNfqws();
                break;

            case 'restart':
                $response = restartNfqws();
                break;

            default:
                http_response_code(405);
                exit();
        }
    } else {
        http_response_code(302);
        header('Location: index.html');
        exit();
    }

    header('Content-Type: application/json; charset=utf-8');
    http_response_code(200);
    echo json_encode($response);
    exit();
}

main();
