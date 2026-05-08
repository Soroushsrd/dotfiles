;;; doom-fel-theme.el --- A dark theme inspired by Warcraft's Fel energy -*- lexical-binding: t; no-byte-compile: t; -*-
;;
;; Keywords: custom themes, faces
;;
;;; Commentary:
;;
;; Colors drawn from Illidan Stormrage's Fel aesthetic:
;;   deep void blacks, fel-green glow, teal lightning, bone horns,
;;   dark ember fire, and muted shadow browns.
;;
;;; Code:

(require 'doom-themes)

;;; Variables
(defgroup doom-fel-theme nil
  "Options for the `doom-fel' theme."
  :group 'doom-themes)

(defcustom doom-fel-brighter-modeline nil
  "If non-nil, more vivid colors will be used to style the mode-line."
  :group 'doom-fel-theme
  :type 'boolean)

(defcustom doom-fel-brighter-comments nil
  "If non-nil, comments will be highlighted in more vivid colors."
  :group 'doom-fel-theme
  :type 'boolean)

(defcustom doom-fel-padded-modeline doom-themes-padded-modeline
  "If non-nil, adds a 4px padding to the mode-line."
  :group 'doom-fel-theme
  :type '(choice integer boolean))

;;; Theme definition
(def-doom-theme doom-fel
    "A dark theme inspired by Warcraft's Fel energy and Illidan Stormrage."

  ;; ── Palette ────────────────────────────────────────────────────────────────
  ;; Sampled from the image:
  ;;   void       deep near-black background (the dark sky/ground)
  ;;   shadow     slightly lighter dark surface
  ;;   pit        overlay / UI chrome surfaces
  ;;   ash        muted brownish-grey (wing membranes)
  ;;   bone       subtle warm grey (horns, edges)
  ;;   dust       main text — off-white with a slight warm tint
  ;;   fel        the bright yellow-green fel fire / glowing eyes (#39ff14 toned down)
  ;;   glow       the slightly softer mid-level green used in blades and runes
  ;;   deep-fel   darker green for subtle accents
  ;;   teal-bolt  the electric teal-cyan of the lightning
  ;;   ember      the golden-amber of smaller flames
  ;;   char       the orange-brown ember glow deep in the rocks
  ;;   blood      the dark red-pink of the wing membrane veins
  ;;   void-hl-l  cursor / subtle highlight
  ;;   void-hl-m  region highlight
  ;;   void-hl-h  bright region / selection
  (
   ;; name          default      256          16
   (void           '("#0a0c08" "#0a0c08"  "black"       ))  ; deepest bg — almost pure black
   (shadow         '("#0f1209" "#0f1209"  "brightblack" ))  ; surface, one step up
   (pit            '("#161c0d" "#161c0d"  "brightblack" ))  ; overlay / panels
   (ash            '("#3d3828" "#3d3828"  "brightblack" ))  ; muted brown-grey
   (bone           '("#6b6450" "#6b6450"  "brightblack" ))  ; subtle warm mid-tone
   (dust           '("#d8d4b8" "#d8d4b8"  "brightwhite" ))  ; main text
   (fel            '("#7fff00" "#7fff00"  "green"       ))  ; bright chartreuse-green (glowing eyes / blades)
   (glow           '("#4ecb1a" "#4ecb1a"  "green"       ))  ; mid fel-green (runes, blade body)
   (deep-fel       '("#2a7a08" "#2a7a08"  "green"       ))  ; deep green accent
   (teal-bolt      '("#00d4cc" "#00d4cc"  "cyan"        ))  ; lightning / teal highlights
   (foam           '("#5ecfb8" "#5ecfb8"  "cyan"        ))  ; softer teal-foam — call sites
   (ember          '("#d4a017" "#d4a017"  "yellow"      ))  ; golden ember fire
   (char           '("#b05a1a" "#b05a1a"  "red"         ))  ; orange-brown deep ember
   (blood          '("#7a3040" "#7a3040"  "red"         ))  ; dark red-pink
   (void-hl-l      '("#131a0b" "#131a0b"  "grey"        ))  ; very subtle highlight
   (void-hl-m      '("#1e3010" "#1e3010"  "grey"        ))  ; selection background
   (void-hl-h      '("#2b4518" "#2b4518"  "grey"        ))  ; brighter selection

   ;; ── Required doom-theme variables ────────────────────────────────────────
   (bg             void)
   (fg             dust)
   (bg-alt         shadow)
   (fg-alt         dust)

   (base0          void)
   (base1          shadow)
   (base2          void-hl-l)
   (base3          pit)
   (base4          void-hl-m)
   (base5          void-hl-h)
   (base6          ash)
   (base7          bone)
   (base8          dust)

   (grey           ash)
   (red            blood)
   (orange         char)
   (green          glow)
   (teal           teal-bolt)
   (yellow         ember)
   (blue           teal-bolt)
   (dark-blue      deep-fel)
   (magenta        fel)
   (violet         glow)
   (cyan           teal-bolt)
   (dark-cyan      deep-fel)

   ;; ── UI variables ─────────────────────────────────────────────────────────
   (highlight      bone)       ; cursor
   (selection      void)
   (region         void-hl-m)  ; visual selection — the green-tinted region
   (vertical-bar   shadow)

   (comments       (if doom-fel-brighter-comments bone ash))
   (doc-comments   (if doom-fel-brighter-comments bone ash))

   ;; ── Syntax ───────────────────────────────────────────────────────────────
   ;; The guiding aesthetic: fel-green for keywords/builtins (the source of power),
   ;; teal for functions/methods (what you *do*), ember/dust for values and types.
   (builtin        glow)
   (constants      fel)
   (functions      teal-bolt)
   (keywords       glow)
   (methods        teal-bolt)
   (numbers        ember)
   (operators      bone)
   (strings        ember)
   (type           teal-bolt)
   (variables      dust)

   (error          blood)
   (success        glow)
   (warning        ember)

   (vc-added       glow)
   (vc-deleted     blood)
   (vc-modified    ember)

   ;; ── Modeline ─────────────────────────────────────────────────────────────
   (modeline-bg              (if doom-fel-brighter-modeline pit shadow))
   (modeline-fg              dust)
   (modeline-bg-alt          (if doom-fel-brighter-modeline ash pit))
   (modeline-fg-alt          dust)
   (modeline-bg-inactive     void)
   (modeline-fg-inactive     bone)
   (modeline-bg-inactive-alt void)
   (modeline-fg-inactive-alt bone)
   (modeline-pad
    (when doom-fel-padded-modeline
      (if (integerp doom-fel-padded-modeline) doom-fel-padded-modeline 4))))

  ;; ── Face overrides ─────────────────────────────────────────────────────────
  (
   ;; Font / syntax
   ((font-lock-comment-face &override)
    :slant 'italic
    :foreground ash
    :background (if doom-fel-brighter-comments (doom-blend deep-fel void 0.10)))
   ((font-lock-type-face &override)          :slant 'italic :foreground teal-bolt)
   ((font-lock-builtin-face &override)       :slant 'italic :foreground glow)
   ((font-lock-function-name-face &override) :foreground teal-bolt)  ; definitions
   ;; Tree-sitter: call sites (set_field, new, push, …)
   ((font-lock-function-call-face &override) :foreground foam)
   ;; Eglot semantic tokens — clangd/rust-analyzer emit these for call sites
   (eglot-semantic-token-face                      :foreground dust)
   (eglot-semantic-token-function-face             :foreground teal-bolt)  ; definitions
   (eglot-semantic-token-function+definition-face  :foreground teal-bolt :weight 'bold)
   (eglot-semantic-token-method-face               :foreground teal-bolt)
   (eglot-semantic-token-method+definition-face    :foreground teal-bolt :weight 'bold)
   ;; The key faces — calls without the definition modifier
   (eglot-semantic-token-function+declaration-face :foreground foam)
   (eglot-semantic-token-method+declaration-face   :foreground foam)
   ((font-lock-keyword-face &override)       :weight 'bold :foreground glow)
   ((font-lock-constant-face &override)      :weight 'bold :foreground fel)
   ((font-lock-string-face &override)        :foreground ember)
   ((font-lock-variable-name-face &override) :foreground dust)
   ((font-lock-number-face &override)        :foreground ember)

   ;; Cursor / hl-line
   (cursor  :background fel)
   (hl-line :background shadow)

   ;; Line numbers
   ((line-number &override)              :foreground ash)
   ((line-number-current-line &override) :foreground glow :weight 'bold)

   ;; Mode line
   (mode-line
    :background modeline-bg
    :foreground modeline-fg
    :box (if modeline-pad `(:line-width ,modeline-pad :color ,modeline-bg)))
   (mode-line-inactive
    :background modeline-bg-inactive
    :foreground modeline-fg-inactive
    :box (if modeline-pad `(:line-width ,modeline-pad :color ,modeline-bg-inactive)))
   (mode-line-emphasis
    :foreground (if doom-fel-brighter-modeline dust bone))

   ;; Doom modeline
   (doom-modeline-bar                   :background glow)
   (doom-modeline-evil-emacs-state      :foreground teal-bolt)
   (doom-modeline-evil-normal-state     :foreground glow)
   (doom-modeline-evil-visual-state     :foreground fel)
   (doom-modeline-evil-insert-state     :foreground ember)

   ;; Company
   (company-tooltip-selection :background glow :foreground void)

   ;; Ivy
   (ivy-current-match                   :background void-hl-m :distant-foreground fg)
   (ivy-minibuffer-match-face-1         :foreground glow   :weight 'bold)
   (ivy-minibuffer-match-face-2         :foreground fel    :weight 'bold)
   (ivy-minibuffer-match-face-3         :foreground ember  :weight 'bold)
   (ivy-minibuffer-match-face-4         :foreground teal-bolt :weight 'bold)
   (ivy-minibuffer-match-highlight      :foreground teal-bolt :weight 'bold)
   (ivy-posframe                        :background pit)

   ;; Vertico / orderless (common in Doom setups)
   (vertico-current :background void-hl-m)

   ;; Helm
   (helm-selection :foreground void :weight 'bold :background glow)

   ;; Markdown
   (markdown-markup-face           :foreground ash)
   (markdown-header-face           :inherit 'bold :foreground fel)
   ((markdown-code-face &override) :background shadow)

   ;; org
   (org-block            :background (doom-blend deep-fel void 0.05) :extend t)
   (org-block-background :background (doom-blend deep-fel void 0.05))
   (org-block-begin-line :background (doom-blend deep-fel void 0.10) :foreground ash :extend t)
   (org-block-end-line   :background (doom-blend deep-fel void 0.10) :foreground ash :extend t)
   (org-level-1          :foreground fel    :weight 'bold)
   (org-level-2          :foreground glow)
   (org-level-3          :foreground teal-bolt)
   (org-level-4          :foreground ember)
   (org-level-5          :foreground fel)
   (org-level-6          :foreground glow)
   (org-level-7          :foreground teal-bolt)
   (org-level-8          :foreground ember)

   ;; Magit / vc diff
   (diff-added             :foreground glow)
   (diff-removed           :foreground blood)
   (diff-changed           :foreground ember)
   (magit-diff-added       :background (doom-blend glow void 0.08) :foreground glow)
   (magit-diff-removed     :background (doom-blend blood void 0.08) :foreground blood)

   ;; Solaire
   (solaire-mode-line-face
    :inherit 'mode-line
    :background modeline-bg-alt
    :box (if modeline-pad `(:line-width ,modeline-pad :color ,modeline-bg-alt)))
   (solaire-mode-line-inactive-face
    :inherit 'mode-line-inactive
    :background modeline-bg-inactive-alt
    :box (if modeline-pad `(:line-width ,modeline-pad :color ,modeline-bg-inactive-alt)))

   ;; Widgets
   (widget-field             :foreground fg :background pit)
   (widget-single-line-field :foreground fg :background pit)

   ;; Swiper
   (swiper-match-face-1 :inherit 'ivy-minibuffer-match-face-1)
   (swiper-match-face-2 :inherit 'ivy-minibuffer-match-face-2)
   (swiper-match-face-3 :inherit 'ivy-minibuffer-match-face-3)
   (swiper-match-face-4 :inherit 'ivy-minibuffer-match-face-4)))

;;; doom-fel-theme.el ends here
