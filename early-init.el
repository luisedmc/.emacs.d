;;; -*- lexical-binding: t; -*-

;; GC só a cada 100 MB durante a inicialização; depois volta para 16 MB,
;; para não ter pausas longas enquanto você digita.
(setq gc-cons-threshold (* 100 1024 1024))
(add-hook 'emacs-startup-hook
          (lambda () (setq gc-cons-threshold (* 16 1024 1024))))

;; Lê até 1 MB por vez de processos externos (LSP, REPL).
(setq read-process-output-max (* 1024 1024))

;; Ativa os pacotes a partir de um único arquivo pré-gerado
;; (package-quickstart.el), atualizado sozinho a cada instalação.
(setq package-quickstart t)
