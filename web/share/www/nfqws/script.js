let token = '';

class UI {
    constructor() {
        TLN.append_line_numbers('config');

        this.buttons = {
            save: ((ui) => {
                const element = document.getElementById('save');

                element.addEventListener('click', async () => {
                    ui.disableUI();

                    const result = await saveFile(ui.tabs.currentFileName, ui.textarea.value);
                    if (!result.status) {
                        ui.textarea.save();
                        element.classList.toggle('hidden', true);
                    } else {
                        alert(`Error: ${result.status}`);
                    }

                    ui.enableUI();
                });

                return {
                    toggle(enabled) {
                        element.classList.toggle('hidden', !enabled);
                    },
                    click() {
                        if (!element.classList.contains('hidden')) {
                            element.click();
                        }
                    }
                };
            })(this),

            reload: ((ui) => {
                const element = document.getElementById('reload');

                element.addEventListener('click', async () => {
                    ui.disableUI();

                    const yesno = confirm('Reload service?');
                    if (yesno) {
                        const result = await reloadNfqws();
                        if (!result.status) {
                            alert(Array.from(result.output).join("\n"));
                        } else {
                            alert(`Error: ${result.status}`);
                        }
                    }

                    ui.enableUI();
                });

                return {};
            })(this),

            restart: ((ui) => {
                const element = document.getElementById('restart');

                element.addEventListener('click', async () => {
                    ui.disableUI();

                    const yesno = confirm('Restart service?');
                    if (yesno) {
                        const result = await restartNfqws();
                        if (!result.status) {
                            alert(Array.from(result.output).join("\n"));
                        } else {
                            alert(`Error: ${result.status}`);
                        }
                    }

                    ui.enableUI();
                });

                return {};
            })(this),
        };

        this.tabs = ((ui) => {
            const element = document.querySelector('nav');
            const tabs = {};
            let currentFile = '';

            return {
                add(filename) {
                    const tab = document.createElement('div');
                    tab.classList.add('nav-tab');
                    tab.textContent = filename;

                    if (!filename.endsWith('.conf') && !filename.endsWith('.list')) {
                        tab.classList.add('secondary');
                        const trash = document.createElement('div');
                        trash.classList.add('nav-trash');
                        trash.setAttribute('title', 'Delete file');

                        trash.addEventListener('click', async (e) => {
                            e.preventDefault();
                            e.stopPropagation();

                            const yesno = confirm('Delete file?');
                            if (!yesno) {
                                return;
                            }

                            ui.disableUI();

                            const result = await removeFile(filename);
                            if (!result.status) {
                                this.remove(filename);
                            } else {
                                alert(`Error: ${result.status}`);
                            }

                            ui.enableUI();
                        });

                        tab.appendChild(trash);
                    }

                    tab.addEventListener('click', async () => ui.loadFile(filename));

                    element.appendChild(tab);
                    tabs[filename] = tab;
                },

                remove(filename) {
                    for (const [key, tab] of Object.entries(tabs)) {
                        if (key === filename) {
                            element.removeChild(tab);
                            delete tabs[key];

                            if (filename === currentFile) {
                                ui.textarea.save();
                                this.activateFirst();
                            }
                            break;
                        }
                    }
                },

                activate(filename) {
                    for (const [key, tab] of Object.entries(tabs)) {
                        tab.classList.toggle('active', filename === key);
                        if (filename === key) {
                            currentFile = filename;
                        }
                    }
                },

                activateFirst() {
                    Object.values(tabs)[0].click();
                },

                get currentFileName() {
                    return currentFile;
                }
            };
        })(this);

        this.textarea = ((ui) => {
            const element = document.getElementById('config');
            let originalText = element.value;
            let textChanged = false;

            element.addEventListener('input', _debounce(() => {
                textChanged = element.value !== originalText;
                ui.buttons.save.toggle(textChanged);
            }, 300));

            element.addEventListener('keydown', (e) => {
                if ((e.ctrlKey || e.metaKey) && e.key === 's') {
                    e.preventDefault();
                    ui.buttons.save.click();
                }
            });

            return {
                get value() {
                    return element.value;
                },
                set value(text) {
                    element.value = text;
                    this.save();
                    // Update line numbers
                    const event = new Event('input');
                    element.dispatchEvent(event);
                },
                get changed() {
                    return textChanged;
                },
                save() {
                    originalText = element.value;
                    textChanged = false;
                    ui.buttons.save.toggle(false);
                },
                disable() {
                    element.setAttribute('disabled', 'disabled');
                },
                enable() {
                    element.removeAttribute('disabled');
                }
            };
        })(this);

        this.version = ((ui) => {
            const element = document.getElementById('version');
            const match = element.textContent.match(/^v([0-9]+)\.([0-9]+)\.([0-9]+)$/);

            return {
                get value() {
                    return match ? [match[1], match[2], match[3]] : null;
                },
                async checkUpdate() {
                    if (!this.value) {
                        return;
                    }

                    const latest = await getLatestVersion();
                    if (!latest) {
                        return;
                    }

                    const updateAvailable = compareVersions(this.value, latest);
                    if (updateAvailable) {
                        const link = document.createElement('a');
                        const tag = `v${latest[0]}.${latest[1]}.${latest[2]}`;
                        link.textContent = `(${tag})`;
                        link.href = `https://github.com/Anonym-tsk/nfqws-keenetic/releases/tag/${tag}`;
                        link.target = '_blank';
                        element.appendChild(link);
                    }
                }
            }
        })(this);
    }

    async loadFile(filename) {
        if (this.textarea.changed) {
            const yesno = confirm('File is not saved, close?');
            if (!yesno) {
                return;
            }
        }

        this.disableUI();

        this.textarea.value = await getFileContent(filename);
        this.tabs.activate(filename);

        this.enableUI();
    }

    disableUI() {
        this.textarea.disable();
    }

    enableUI() {
        this.textarea.enable();
    }
}

function _debounce(func, ms) {
    let timeout;

    function wrapper(..._args) {
        const _this = this;

        if (timeout) {
            window.clearTimeout(timeout);
        }

        timeout = window.setTimeout(() => {
            func.apply(_this, _args);
        }, ms);
    }

    return wrapper;
}

async function _postData(data) {
    const formData = new FormData();
    formData.append('token', token);
    for (const [key, value] of Object.entries(data)) {
        formData.append(key, value);
    }
    try {
        const response = await fetch('index.php', {
            method: 'POST',
            body: formData,
        });
        if (response.ok) {
            return await response.json();
        } else {
            return {status: response.status, statusText: response.statusText};
        }
    } catch (e) {
        return {status: 975};
    }
}

async function getFiles() {
    const data = await _postData({cmd: 'filenames'});
    token = data.token;
    return data.files || [];
}

async function getFileContent(filename) {
    const data = await _postData({cmd: 'filecontent', filename});
    return data.content || '';
}

async function saveFile(filename, content) {
    return _postData({cmd: 'filesave', filename, content});
}

async function removeFile(filename) {
    return _postData({cmd: 'fileremove', filename});
}

async function reloadNfqws() {
    return _postData({cmd: 'reload'});
}

async function restartNfqws() {
    return _postData({cmd: 'restart'});
}

async function getLatestVersion() {
    try {
        const response = await fetch('https://api.github.com/repos/Anonym-tsk/nfqws-keenetic/releases/latest');
        const data = await response.json();
        const tag = data.tag_name;
        const match = tag.match(/^v([0-9]+)\.([0-9]+)\.([0-9]+)$/);
        return [match[1], match[2], match[3]];
    } catch (e) {
        return null;
    }
}

function compareVersions(current, latest) {
    const v1 = latest[0] - current[0];
    const v2 = latest[1] - current[1];
    const v3 = latest[2] - current[2];
    if (v1) return v1 > 0;
    if (v2) return v2 > 0;
    if (v3) return v3 > 0;
    return false;
}

async function main() {
    const ui = new UI();
    ui.version.checkUpdate();

    const files = await getFiles();
    for (const filename of files) {
        ui.tabs.add(filename);
    }
    ui.tabs.activateFirst();
}

main();
