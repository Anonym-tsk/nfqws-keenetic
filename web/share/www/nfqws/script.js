class UI {
    constructor() {
        TLN.append_line_numbers('config');

        this.buttons = this._initButtons();
        this.tabs = this._initTabs();
        this.textarea = this._initTextarea();
        this.version = this._initVersion();
        this.status = this._initStatus();
    }

    _initTabs() {
        const element = document.querySelector('nav');
        const tabs = {};
        let currentFile = '';

        const add = (filename) => {
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

                    this.disableUI();

                    const result = await removeFile(filename);
                    if (!result.status) {
                        remove(filename);
                    } else {
                        alert(`Error: ${result.status}`);
                    }

                    this.enableUI();
                });

                tab.appendChild(trash);
            }

            tab.addEventListener('click', async () => this.loadFile(filename));

            element.appendChild(tab);
            tabs[filename] = tab;
        };

        const remove = (filename) => {
            for (const [key, tab] of Object.entries(tabs)) {
                if (key === filename) {
                    element.removeChild(tab);
                    delete tabs[key];

                    if (filename === currentFile) {
                        this.textarea.save();
                        activateFirst();
                    }
                    break;
                }
            }
        };

        const activate = (filename) => {
            for (const [key, tab] of Object.entries(tabs)) {
                tab.classList.toggle('active', filename === key);
                if (filename === key) {
                    currentFile = filename;
                }
            }
        };

        const activateFirst = () => {
            Object.values(tabs)[0].click();
        };

        return {
            add,
            remove,
            activate,
            activateFirst,
            get currentFileName() {
                return currentFile;
            }
        };
    }

    _initTextarea() {
        const element = document.getElementById('config');
        let originalText = element.value;
        let textChanged = false;

        const save = () => {
            originalText = element.value;
            textChanged = false;
            this.buttons.toggle(false);
        };

        const disable = () => {
            element.setAttribute('disabled', 'disabled');
        };

        const enable = () => {
            element.removeAttribute('disabled');
        };

        element.addEventListener('input', _debounce(() => {
            textChanged = element.value !== originalText;
            this.buttons.toggle(textChanged);
        }, 300));

        element.addEventListener('keydown', (e) => {
            if ((e.ctrlKey || e.metaKey) && e.key === 's') {
                e.preventDefault();
                this.buttons.click();
            }
        });

        return {
            get value() {
                return element.value;
            },
            set value(text) {
                element.value = text;
                save();
                // Update line numbers
                const event = new Event('input');
                element.dispatchEvent(event);
            },
            get changed() {
                return textChanged;
            },
            save,
            disable,
            enable,
        };
    }

    _initVersion() {
        const element = document.getElementById('version');
        const match = element.textContent.match(/^v([0-9]+)\.([0-9]+)\.([0-9]+)$/);

        const value = () => {
            return match ? [match[1], match[2], match[3]] : null;
        };

        const checkUpdate = async () => {
            if (!value()) {
                return;
            }

            const latest = await getLatestVersion();
            if (!latest) {
                return;
            }

            const updateAvailable = compareVersions(value(), latest);
            if (updateAvailable) {
                const link = document.createElement('a');
                const tag = `v${latest[0]}.${latest[1]}.${latest[2]}`;
                link.textContent = `(${tag})`;
                link.href = `https://github.com/Anonym-tsk/nfqws-keenetic/releases/tag/${tag}`;
                link.target = '_blank';
                element.appendChild(link);
            }
        };

        return {
            get value() {
                return value();
            },
            checkUpdate,
        }
    }

    _initStatus() {
        const statusOk = document.getElementById('status-running');
        const statusFail = document.getElementById('status-stopped');

        return {
            set(status) {
                statusOk.classList.toggle('hidden', !status);
                statusFail.classList.toggle('hidden', status);
            }
        }
    }

    _initButtons() {
        const btnReload = document.getElementById('reload');
        const btnRestart = document.getElementById('restart');
        const btnStop = document.getElementById('stop');
        const btnStart = document.getElementById('start');
        const btnDropdown = document.getElementById('dropdown');
        const menuDropdown = document.getElementById('dropdown-menu');
        const btnSave = document.getElementById('save');

        const nfqwsActionClick = async (action, text) => {
            this.disableUI();
            const yesno = confirm(text);
            if (yesno) {
                const result = await serviceAction(action);
                if (!result.status) {
                    alert(Array.from(result.output).join("\n"));

                    if (action === 'stop') {
                        this.status.set(false);
                    } else if (action === 'start' || action === 'restart') {
                        this.status.set(true);
                    }
                } else {
                    alert(`Error: ${result.status}`);
                }
            }

            this.enableUI();
        };

        btnReload.addEventListener('click', () => nfqwsActionClick('reload', 'Reload service?'));
        btnRestart.addEventListener('click', () => nfqwsActionClick('restart', 'Restart service?'));
        btnStop.addEventListener('click', () => nfqwsActionClick('stop', 'Stop service?'));
        btnStart.addEventListener('click', () => nfqwsActionClick('start', 'Start service?'));

        btnDropdown.addEventListener('click', () => {
            menuDropdown.classList.toggle('hidden');
        });

        const hideMenu = _debounce(() => {
            menuDropdown.classList.add('hidden');
        }, 500);
        btnDropdown.addEventListener('focusout', hideMenu);
        menuDropdown.addEventListener('mouseleave', hideMenu);
        menuDropdown.addEventListener('mouseenter', () => hideMenu.stop());

        btnSave.addEventListener('click', async () => {
            this.disableUI();

            const result = await saveFile(this.tabs.currentFileName, this.textarea.value);
            if (!result.status) {
                this.textarea.save();
                this.buttons.toggle(true);
            } else {
                alert(`Error: ${result.status}`);
            }

            this.enableUI();
        });

        return {
            toggle(enabled) {
                btnSave.classList.toggle('hidden', !enabled);
            },
            click() {
                if (!btnSave.classList.contains('hidden')) {
                    btnSave.click();
                }
            },
        };
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

    wrapper.stop = () => {
        if (timeout) {
            window.clearTimeout(timeout);
        }
    };

    return wrapper;
}

async function _postData(data) {
    const formData = new FormData();
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
    return _postData({cmd: 'filenames'});
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

async function serviceAction(action) {
    return _postData({cmd: action});
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

    const response = await getFiles();
    ui.status.set(response.service);

    if (!response.files.length) {
        return;
    }

    for (const filename of response.files) {
        ui.tabs.add(filename);
    }
    ui.tabs.activateFirst();
}

main();
