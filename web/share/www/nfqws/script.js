class UI {
    constructor() {
        TLN.append_line_numbers('config');

        this.$tabs = document.querySelector('nav');

        this.buttons = this._initButtons();
        this.tabs = this._initTabs();
        this.textarea = this._initTextarea();
        this.version = this._initVersion();
        this.popup = this._initPopups();
        this.login = this._initLoginForm();
    }

    _initTabs() {
        const tabs = {};
        let currentFile = '';

        const add = (filename) => {
            const tab = document.createElement('div');
            tab.classList.add('nav-tab');
            tab.textContent = filename;

            const isConf = filename.endsWith('.conf');
            const isList = filename.endsWith('.list');
            const isLog = filename.endsWith('.log');

            if (!isConf && !isList && !isLog) {
                tab.classList.add('secondary');
                const trash = document.createElement('div');
                trash.classList.add('nav-trash');
                trash.setAttribute('title', 'Delete file');

                trash.addEventListener('click', async (e) => {
                    e.preventDefault();
                    e.stopPropagation();

                    const yesno = await this.popup.confirm('Delete file?');
                    if (!yesno) {
                        return;
                    }

                    const result = await removeFile(filename);
                    if (!result.status) {
                        remove(filename);
                    } else {
                        this.popup.alert(`remove ${filename}`, `Error: ${result.status}`);
                    }
                });

                tab.appendChild(trash);
            }

            tab.addEventListener('click', async () => this.loadFile(filename));

            this.$tabs.appendChild(tab);
            tabs[filename] = tab;
        };

        const remove = (filename) => {
            for (const [key, tab] of Object.entries(tabs)) {
                if (key === filename) {
                    tab.parentNode.removeChild(tab);
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
            this.setChanged(false);
        };

        element.addEventListener('input', _debounce(() => {
            textChanged = element.value !== originalText;
            this.setChanged(textChanged);
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
            disabled(status) {
                if (status) {
                    element.setAttribute('disabled', 'disabled');
                } else {
                    element.removeAttribute('disabled');
                }
            },
            readonly(status) {
                if (status) {
                    element.setAttribute('readonly', 'readonly');
                } else {
                    element.removeAttribute('readonly');
                }
            },
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

    _initPopups() {
        const element = document.getElementById('alert');
        const alertContent = element.querySelector('.popup-content');
        const buttonClose = element.querySelector('.popup-close');
        const buttonYes = element.querySelector('.popup-yes');
        const buttonNo = element.querySelector('.popup-no');

        const alert = (...text) => {
            this.disableUI();
            alertContent.textContent = `> ${text.join("\n")}`;
            element.classList.add('alert');
            element.classList.remove('hidden', 'confirm', 'locked');
        };

        const hide = () => {
            element.classList.add('hidden');
            element.classList.remove('locked');
            this.enableUI();
        }

        const confirm = async (text) => {
            this.disableUI();
            alertContent.textContent = text;
            element.classList.add('confirm');
            element.classList.remove('hidden', 'alert', 'locked');

            return new Promise((resolve) => {
                buttonYes.addEventListener('click', function ok() {
                    buttonYes.removeEventListener('click', ok);
                    resolve(true);
                });
                buttonNo.addEventListener('click', function fail() {
                    buttonNo.removeEventListener('click', fail);
                    resolve(false);
                });
            });
        };

        const process = async (text, fn, ...args) => {
            this.disableUI();
            alertContent.textContent = `> ${text}\n`;
            element.classList.add('alert', 'locked');
            element.classList.remove('hidden', 'confirm');
            let status = true;

            const result = await fn(...args);
            if (!result.status) {
                alertContent.textContent += Array.from(result.output).join("\n");
            } else {
                alertContent.textContent += `Error: ${result.status}`;
                status = false;
            }
            element.classList.remove('locked');

            return new Promise((resolve) => {
                buttonClose.addEventListener('click', function close() {
                    buttonYes.removeEventListener('click', close);
                    resolve(status);
                });
            });
        };

        buttonClose.addEventListener('click', hide);
        buttonYes.addEventListener('click', hide);
        buttonNo.addEventListener('click', hide);

        return {
            alert,
            confirm,
            process,
        }
    }

    _initLoginForm() {
        // TODO: logout
        const element = document.getElementById('login-form');
        const login = document.getElementById('login');
        const password = document.getElementById('password');
        const buttonYes = element.querySelector('.popup-yes');

        const submit = async () => {
            element.classList.add('hidden');
            const result = await _postData({cmd: 'login', user: login.value, password: password.value});
            if (!result.status) {
                location.reload();
            }
        };

        login.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') {
                submit()
            }
        });

        password.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') {
                submit()
            }
        });

        buttonYes.addEventListener('click', submit);

        return {
            show() {
                login.value = '';
                password.value = '';
                element.classList.remove('hidden');
            }
        }
    }

    setStatus(status) {
        document.body.classList.toggle('running', status);
    }

    setChanged(status) {
        document.body.classList.toggle('changed', status);
    }

    isChanged() {
        return document.body.classList.contains('changed');
    }

    _initButtons() {
        const btnReload = document.getElementById('reload');
        const btnRestart = document.getElementById('restart');
        const btnStop = document.getElementById('stop');
        const btnStart = document.getElementById('start');
        const btnDropdown = document.getElementById('dropdown');
        const menuDropdown = document.getElementById('dropdown-menu');
        const btnSave = document.getElementById('save');
        const btnTheme = document.getElementById('theme');
        const btnUpdate = document.getElementById('update');
        const btnUpgrade = document.getElementById('upgrade');

        const nfqwsActionClick = async (action, text) => {
            const yesno = await this.popup.confirm(text);
            if (!yesno) {
                return;
            }

            const result = await this.popup.process(`nfqws-keenetic ${action}`, serviceAction, action);
            if (result) {
                if (action === 'stop') {
                    this.setStatus(false);
                } else if (action === 'start' || action === 'restart') {
                    this.setStatus(true);
                }
            }

            return result;
        };

        btnReload.addEventListener('click', () => nfqwsActionClick('reload', 'Reload service?'));
        btnRestart.addEventListener('click', () => nfqwsActionClick('restart', 'Restart service?'));
        btnStop.addEventListener('click', () => nfqwsActionClick('stop', 'Stop service?'));
        btnStart.addEventListener('click', () => nfqwsActionClick('start', 'Start service?'));
        btnTheme.addEventListener('click', () => this.toggleTheme());
        btnUpdate.addEventListener('click', () => nfqwsActionClick('update', 'Update packages list?'));
        btnUpgrade.addEventListener('click', async () => {
            const result = await nfqwsActionClick('upgrade', 'Upgrade nfqws-keenetic?');
            if (result) {
                // Not using window.location.reload() because need clear cache
                window.location.href = window.location.href;
            }
        });

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
            if (!this.isChanged()) {
                return;
            }

            const result = await saveFile(this.tabs.currentFileName, this.textarea.value);
            if (!result.status) {
                this.textarea.save();
            } else {
                this.popup.alert(`save ${this.tabs.currentFileName}`, `Error: ${result.status}`);
            }
        });

        return {
            click() {
                btnSave.click();
            },
        };
    }

    async loadFile(filename) {
        if (this.textarea.changed) {
            const yesno = await this.popup.confirm('File is not saved, close?');
            if (!yesno) {
                return;
            }
        }

        this.tabs.activate(filename);
        this.textarea.value = await getFileContent(filename);
        this.textarea.readonly(filename.endsWith('.log'));
    }

    disableUI() {
        this.textarea.disabled(true);
        document.body.classList.add('disabled');
    }

    enableUI() {
        this.textarea.disabled(false);
        document.body.classList.remove('disabled', 'unknown');
    }

    toggleTheme() {
        const root = document.querySelector(':root');
        const theme = (root.dataset.theme === 'dark') ? 'light' : 'dark';
        localStorage.setItem('theme', theme);
        root.dataset.theme = theme;
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

    ui.disableUI();
    try {
        const response = await fetch('index.php', {
            method: 'POST',
            body: formData,
        });

        if (response.ok) {
            ui.enableUI();
            return await response.json();
        }

        if (response.status === 401) {
            ui?.login.show();
        } else {
            ui.enableUI();
        }
        return {status: response.status, statusText: response.statusText};
    } catch (e) {
        ui.enableUI();
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

const ui = new UI();
ui.version.checkUpdate();

const response = await getFiles();
ui.setStatus(response.service);

if (response.files?.length) {
    for (const filename of response.files) {
        ui.tabs.add(filename);
    }
    ui.tabs.activateFirst();
}
