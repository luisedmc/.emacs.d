## .emacs.d

terminal only emacs for common lisp, using built-in features wherever possible

setup on a new machine:

```sh
git clone <repo> ~/.emacs.d
ln -s ~/.emacs.d/sbclrc ~/.sbclrc
curl -O https://beta.quicklisp.org/quicklisp.lisp
sbcl --non-interactive --load quicklisp.lisp \
     --eval '(quicklisp-quickstart:install :path "~/.emacs.d/quicklisp/")'
```

### UI

- `gruber-darker`

### Maps

| key | action |
| --- | --- |
| `S-<arrows>` | move between windows |
| `C-x o` `o` `o`... | keep switching windows (repeat) |
| `C-x C-f` / `C-x b` / `M-x` | vertical fuzzy completion |
| `M-j` | accept typed text in the completion list |
| `TAB` | accept inline completion preview |
| `C-s` | search with match count |
| `M-s o` | list matching lines in buffer |
| `C-x p f` | find file in project |
| `C-x p g` | grep project with ripgrep |
| `M-x recentf-open` | recent files |
| `M-w` | copy (also to the macos clipboard) |

maps for slime:

| key | action |
| --- | --- |
| `M-x slime` | start sbcl and the repl |
| `C-c C-c` | compile function at point |
| `C-c C-k` | compile and load file |
| `C-x C-e` / `C-c C-j` | eval expression before point in the repl |
| `C-c C-y` | call function at point in the repl |
| `C-c C-z` | go to the repl |
| `C-c ~` | sync repl package and directory with the buffer |
| `M-.` / `M-,` | go to definition / back |
| `C-c TAB` | complete symbol |
| `C-c C-d d` | describe symbol |
| `C-c C-d h` | open the hyperspec |
| `,ql` | quickload a system (in the repl) |
| `M-x slime-quit-lisp` | stop sbcl |

### Packages

- `slime` from melpa, with `slime-fancy` and `slime-quicklisp`
- `gruber-darker-theme` from melpa

