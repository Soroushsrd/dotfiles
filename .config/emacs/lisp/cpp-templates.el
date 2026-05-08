;;; cpp-templates.el --- C++ project and class templates for Doom Emacs -*- lexical-binding: t; -*-

;;; Commentary:
;; This package provides convenient templates for C++ development in Doom Emacs.
;; Features:
;; - Project scaffolding with CMakeLists.txt
;; - Class creation (header + source pairs)
;; - Common C++ code snippets
;; - Automatic header guards

;;; Code:

(require 'subr-x)

;;; Configuration Variables

(defvar cpp-template-author-name user-full-name
  "Author name to use in file headers.")

(defvar cpp-template-author-email user-mail-address
  "Author email to use in file headers.")

(defvar cpp-template-license "MIT"
  "Default license type for new projects.")

(defvar cpp-template-std-version "c++23"
  "Default C++ standard version.")

(defvar cpp-template-namespace-default ""
  "Default namespace for new classes (empty for no namespace).")

;;; Helper Functions

(defun cpp-template--get-header-guard (filename)
  "Generate a header guard macro name from FILENAME."
  (let ((base (file-name-nondirectory filename)))
    (upcase (replace-regexp-in-string
             "[^a-zA-Z0-9]" "_"
             (concat (file-name-sans-extension base) "_H")))))

(defun cpp-template--get-class-name-from-file (filename)
  "Extract a class name from FILENAME using PascalCase convention."
  (let* ((base (file-name-sans-extension (file-name-nondirectory filename)))
         (parts (split-string base "[_-]"))
         (capitalized (mapcar #'capitalize parts)))
    (string-join capitalized "")))

(defun cpp-template--insert-file-header (filename &optional description)
  "Insert a file header comment block for FILENAME with optional DESCRIPTION."
  (insert (format "/**\n * @file %s\n" (file-name-nondirectory filename)))
  (when description
    (insert (format " * @brief %s\n" description)))
  (insert (format " * @author %s <%s>\n" cpp-template-author-name cpp-template-author-email))
  (insert (format " * @date %s\n */\n\n" (format-time-string "%Y-%m-%d"))))

(defun cpp-template--create-directory-structure (base-dir)
  "Create standard C++ project directory structure under BASE-DIR."
  (let ((dirs '("src" "include" "tests" "build" "docs")))
    (dolist (dir dirs)
      (make-directory (expand-file-name dir base-dir) t))))

;;; Interactive Commands - Project Creation

;;;###autoload
(defun cpp-template-new-project (project-name directory)
  "Create a new C++ project named PROJECT-NAME in DIRECTORY.
This creates the directory structure, CMakeLists.txt, a main.cpp,
and a README.md file."
  (interactive
   (list (read-string "Project name: ")
         (read-directory-name "Project directory: ")))
  (let* ((project-dir (expand-file-name project-name directory))
         (src-dir (expand-file-name "src" project-dir))
         (include-dir (expand-file-name "include" project-dir))
         (main-file (expand-file-name "main.cpp" project-dir))
         (cmake-file (expand-file-name "CMakeLists.txt" project-dir))
         (readme-file (expand-file-name "README.md" project-dir))
         (gitignore-file (expand-file-name ".gitignore" project-dir)))

    ;; Create directory structure
    (cpp-template--create-directory-structure project-dir)

    ;; Create CMakeLists.txt
    (with-temp-file cmake-file
      (insert (format "cmake_minimum_required(VERSION 3.5)\n"))
      (insert (format "project(%s VERSION 0.1.0 LANGUAGES CXX)\n\n" project-name))
      (insert "set(CMAKE_EXPORT_COMPILE_COMMANDS ON)\n")
      (insert (format "set(CMAKE_CXX_STANDARD %s)\n"
                      (replace-regexp-in-string "c\\+\\+" "" cpp-template-std-version)))
      (insert "set(CMAKE_CXX_STANDARD_REQUIRED ON)\n")
      (insert "set(CMAKE_CXX_EXTENSIONS OFF)\n\n")
      (insert "# Compiler warnings\n")
      (insert "if(MSVC)\n")
      (insert "    add_compile_options(/W4)\n")
      (insert "else()\n")
      (insert "    add_compile_options(-Wall -Wextra -Wpedantic)\n")
      (insert "endif()\n\n")
      (insert "# Include directories\n")
      (insert "include_directories(${PROJECT_SOURCE_DIR}/include)\n\n")
      (insert "# Source files\n")
      (insert "file(GLOB_RECURSE SOURCES main.cpp\n\"src/*.cpp\")\n\n")
      (insert "# Executable\n")
      (insert (format "add_executable(${PROJECT_NAME} ${SOURCES})\n\n"))
      (insert "# Testing\n")
      (insert "enable_testing()\n")
      (insert "add_subdirectory(tests)\n"))

    ;; Create main.cpp
    (with-temp-file main-file
      (cpp-template--insert-file-header main-file "Main entry point")
      (insert "#include <iostream>\n\n")
      (insert "int main(int argc, char* argv[]) {\n")
      (insert "    std::cout << \"Hello from " project-name "!\" << std::endl;\n")
      (insert "    return 0;\n")
      (insert "}\n"))

    ;; Create README.md
    (with-temp-file readme-file
      (insert (format "# %s\n\n" project-name))
      (insert "## Description\n\n")
      (insert "TODO: Add project description\n\n")
      (insert "## Building\n\n")
      (insert "```bash\n")
      (insert "mkdir build && cd build\n")
      (insert "cmake ..\n")
      (insert "make\n")
      (insert "```\n\n")
      (insert "## Usage\n\n")
      (insert "```bash\n")
      (insert (format "./%s\n" project-name))
      (insert "```\n\n")
      (insert "## License\n\n")
      (insert (format "%s\n" cpp-template-license)))

    ;; Create .gitignore
    (with-temp-file gitignore-file
      (insert "# Build directories\n")
      (insert "build/\n")
      (insert "cmake-build-*/\n\n")
      (insert "# Compiled files\n")
      (insert "*.o\n")
      (insert "*.so\n")
      (insert "*.a\n")
      (insert "*.exe\n\n")
      (insert "# IDE files\n")
      (insert ".vscode/\n")
      (insert ".idea/\n")
      (insert "*.swp\n")
      (insert "*~\n"))

    ;; Create tests CMakeLists.txt
    (with-temp-file (expand-file-name "CMakeLists.txt" (expand-file-name "tests" project-dir))
      (insert "# Add test executable here\n")
      (insert "# add_executable(test_main test_main.cpp)\n")
      (insert "# add_test(NAME test_main COMMAND test_main)\n"))

    (message "Created C++ project: %s" project-dir)
    (dired project-dir)))

;;; Interactive Commands - Class Creation

(defun cpp-template--find-project-root ()
  "Find the project root by looking for CMakeLists.txt.
Returns the directory path or nil if not found."
  (let ((current-dir (or (buffer-file-name) default-directory)))
    (locate-dominating-file current-dir "CMakeLists.txt")))

;;;###autoload
(defun cpp-template-new-class (class-name &optional namespace)
  "Create a new C++ class with CLASS-NAME.
Creates both header (.h) and implementation (.cpp) files.
If in a project with CMakeLists.txt, places header in include/ and source in src/.
Otherwise creates files in current directory.
Optional NAMESPACE wraps the class in a namespace."
  (interactive
   (list (read-string "Class name: ")
         (read-string (format "Namespace (default: %s): " cpp-template-namespace-default)
                      nil nil cpp-template-namespace-default)))
  (let* ((project-root (cpp-template--find-project-root))
         (header-dir (if project-root
                         (expand-file-name "include" project-root)
                       default-directory))
         (source-dir (if project-root
                         (expand-file-name "src" project-root)
                       default-directory))
         (header-file (expand-file-name (concat class-name ".h") header-dir))
         (source-file (expand-file-name (concat class-name ".cpp") source-dir))
         (header-guard (cpp-template--get-header-guard (concat class-name ".h")))
         (use-namespace (and namespace (not (string-empty-p namespace)))))

    ;; Ensure directories exist
    (when project-root
      (make-directory header-dir t)
      (make-directory source-dir t))

    ;; Create header file
    (find-file header-file)
    (cpp-template--insert-file-header (concat class-name ".h")
                                      (format "Declaration of %s class" class-name))
    (insert (format "#ifndef %s\n" header-guard))
    (insert (format "#define %s\n\n" header-guard))

    (when use-namespace
      (insert (format "namespace %s {\n\n" namespace)))

    (insert (format "class %s {\n" class-name))
    (insert "public:\n")
    (insert (format "    %s();\n" class-name))
    (insert (format "    ~%s();\n\n" class-name))
    (insert "    // Delete copy constructor and assignment operator\n")
    (insert (format "    %s(const %s&) = delete;\n" class-name class-name))
    (insert (format "    %s& operator=(const %s&) = delete;\n\n" class-name class-name))
    (insert "private:\n")
    (insert "    // Private members\n")
    (insert "};\n\n")

    (when use-namespace
      (insert (format "} // namespace %s\n\n" namespace)))

    (insert (format "#endif // %s\n" header-guard))
    (save-buffer)

    ;; Create source file
    (find-file source-file)
    (cpp-template--insert-file-header (concat class-name ".cpp")
                                      (format "Implementation of %s class" class-name))
    (insert (format "#include \"%s.h\"\n\n" class-name))

    (when use-namespace
      (insert (format "namespace %s {\n\n" namespace)))

    (insert (format "%s::%s() {\n" class-name class-name))
    (insert "    // Constructor implementation\n")
    (insert "}\n\n")
    (insert (format "%s::~%s() {\n" class-name class-name))
    (insert "    // Destructor implementation\n")
    (insert "}\n\n")

    (when use-namespace
      (insert (format "} // namespace %s\n" namespace)))

    (save-buffer)
    (if project-root
        (message "Created class %s:\n  Header: %s\n  Source: %s"
                 class-name header-file source-file)
      (message "Created class %s in current directory" class-name))))

;;;###autoload
(defun cpp-template-new-header-only-class (class-name &optional namespace)
  "Create a header-only C++ class with CLASS-NAME.
If in a project with CMakeLists.txt, places header in include/.
Otherwise creates file in current directory.
Optional NAMESPACE wraps the class in a namespace."
  (interactive
   (list (read-string "Class name: ")
         (read-string (format "Namespace (default: %s): " cpp-template-namespace-default)
                      nil nil cpp-template-namespace-default)))
  (let* ((project-root (cpp-template--find-project-root))
         (header-dir (if project-root
                         (expand-file-name "include" project-root)
                       default-directory))
         (header-file (expand-file-name (concat class-name ".h") header-dir))
         (header-guard (cpp-template--get-header-guard (concat class-name ".h")))
         (use-namespace (and namespace (not (string-empty-p namespace)))))

    ;; Ensure directory exists
    (when project-root
      (make-directory header-dir t))

    (find-file header-file)
    (cpp-template--insert-file-header (concat class-name ".h")
                                      (format "Header-only %s class" class-name))
    (insert (format "#ifndef %s\n" header-guard))
    (insert (format "#define %s\n\n" header-guard))

    (when use-namespace
      (insert (format "namespace %s {\n\n" namespace)))

    (insert (format "class %s {\n" class-name))
    (insert "public:\n")
    (insert (format "    %s() {}\n" class-name))
    (insert (format "    ~%s() {}\n\n" class-name))
    (insert "    // Delete copy constructor and assignment operator\n")
    (insert (format "    %s(const %s&) = delete;\n" class-name class-name))
    (insert (format "    %s& operator=(const %s&) = delete;\n\n" class-name class-name))
    (insert "private:\n")
    (insert "    // Private members\n")
    (insert "};\n\n")

    (when use-namespace
      (insert (format "} // namespace %s\n\n" namespace)))

    (insert (format "#endif // %s\n" header-guard))
    (save-buffer)
    (if project-root
        (message "Created header-only class %s in %s" class-name header-file)
      (message "Created header-only class %s in current directory" class-name))))

;;; Interactive Commands - Code Snippets

;;;###autoload
(defun cpp-template-organize-current-file ()
  "Move current file to the appropriate project directory.
Moves .h/.hpp files to include/ and .cpp/.cc files to src/."
  (interactive)
  (let* ((current-file (buffer-file-name))
         (project-root (cpp-template--find-project-root)))
    (unless current-file
      (user-error "Current buffer is not visiting a file"))
    (unless project-root
      (user-error "Not in a project with CMakeLists.txt"))

    (let* ((filename (file-name-nondirectory current-file))
           (extension (file-name-extension filename))
           (target-dir (cond
                        ((member extension '("h" "hpp" "hxx"))
                         (expand-file-name "include" project-root))
                        ((member extension '("cpp" "cc" "cxx"))
                         (expand-file-name "src" project-root))
                        (t (user-error "Unknown file extension: %s" extension))))
           (target-file (expand-file-name filename target-dir)))

      (if (string= current-file target-file)
          (message "File is already in the correct location")
        (when (y-or-n-p (format "Move %s to %s? " filename target-dir))
          (make-directory target-dir t)
          (rename-file current-file target-file)
          (kill-buffer)
          (find-file target-file)
          (message "Moved to %s" target-file))))))

;;;###autoload
(defun cpp-template-organize-all-files ()
  "Organize all C++ files in current directory into include/ and src/.
Moves all .h/.hpp files to include/ and .cpp/.cc files to src/."
  (interactive)
  (let ((project-root (cpp-template--find-project-root)))
    (unless project-root
      (user-error "Not in a project with CMakeLists.txt"))

    (let* ((current-dir default-directory)
           (header-files (directory-files current-dir t "\\.\\(h\\|hpp\\|hxx\\)$"))
           (source-files (directory-files current-dir t "\\.\\(cpp\\|cc\\|cxx\\)$"))
           (include-dir (expand-file-name "include" project-root))
           (src-dir (expand-file-name "src" project-root)))

      (when (and (or header-files source-files)
                 (y-or-n-p (format "Move %d header(s) and %d source(s) to include/ and src/? "
                                   (length header-files) (length source-files))))
        (make-directory include-dir t)
        (make-directory src-dir t)

        ;; Move headers
        (dolist (file header-files)
          (let ((target (expand-file-name (file-name-nondirectory file) include-dir)))
            (unless (string= file target)
              (rename-file file target t)
              (message "Moved %s to include/" (file-name-nondirectory file)))))

        ;; Move sources
        (dolist (file source-files)
          (let ((target (expand-file-name (file-name-nondirectory file) src-dir)))
            (unless (string= file target)
              (rename-file file target t)
              (message "Moved %s to src/" (file-name-nondirectory file)))))

        (message "Organization complete! %d files moved."
                 (+ (length header-files) (length source-files)))))))

;;; Interactive Commands - Code Snippets

;;;###autoload
(defun cpp-template-insert-method ()
  "Insert a method declaration or definition template."
  (interactive)
  (let* ((return-type (read-string "Return type (default: void): " nil nil "void"))
         (method-name (read-string "Method name: "))
         (params (read-string "Parameters (e.g., int x, double y): "))
         (is-const (y-or-n-p "Const method? "))
         (in-header (y-or-n-p "In header (declaration)? ")))

    (if in-header
        (insert (format "    %s %s(%s)%s;\n"
                        return-type method-name params
                        (if is-const " const" "")))
      (insert (format "%s ClassName::%s(%s)%s {\n"
                      return-type method-name params
                      (if is-const " const" "")))
      (insert "    // TODO: Implement\n")
      (insert "}\n"))))

;;;###autoload
(defun cpp-template-insert-getter-setter ()
  "Insert getter and setter methods for a member variable."
  (interactive)
  (let* ((type (read-string "Member type: "))
         (name (read-string "Member name (without m_ prefix): "))
         (member-name (concat "m_" name))
         (getter-name (concat "get" (capitalize name)))
         (setter-name (concat "set" (capitalize name))))

    (insert (format "    // Getter\n"))
    (insert (format "    %s %s() const { return %s; }\n\n"
                    type getter-name member-name))
    (insert (format "    // Setter\n"))
    (insert (format "    void %s(const %s& value) { %s = value; }\n"
                    setter-name type member-name))))

;;;###autoload
(defun cpp-template-insert-singleton-pattern ()
  "Insert singleton pattern boilerplate for current class."
  (interactive)
  (let ((class-name (read-string "Class name: ")))
    (insert "public:\n")
    (insert (format "    static %s& getInstance() {\n" class-name))
    (insert (format "        static %s instance;\n" class-name))
    (insert "        return instance;\n")
    (insert "    }\n\n")
    (insert "    // Delete copy and move constructors and assign operators\n")
    (insert (format "    %s(const %s&) = delete;\n" class-name class-name))
    (insert (format "    %s(%s&&) = delete;\n" class-name class-name))
    (insert (format "    %s& operator=(const %s&) = delete;\n" class-name class-name))
    (insert (format "    %s& operator=(%s&&) = delete;\n\n" class-name class-name))
    (insert "private:\n")
    (insert (format "    %s() {}\n" class-name))
    (insert (format "    ~%s() {}\n" class-name))))

;;;###autoload
(defun cpp-template-insert-smart-ptr-typedef ()
  "Insert smart pointer typedefs for current class."
  (interactive)
  (let ((class-name (read-string "Class name: ")))
    (insert (format "using %sPtr = std::shared_ptr<%s>;\n" class-name class-name))
    (insert (format "using %sUniquePtr = std::unique_ptr<%s>;\n" class-name class-name))
    (insert (format "using %sWeakPtr = std::weak_ptr<%s>;\n" class-name class-name))))

;;;###autoload
(defun cpp-template-insert-pimpl-pattern ()
  "Insert PIMPL (Pointer to Implementation) pattern boilerplate."
  (interactive)
  (let ((class-name (read-string "Class name: ")))
    (insert "private:\n")
    (insert "    class Impl;\n")
    (insert "    std::unique_ptr<Impl> pImpl;\n")))

;;; Key Bindings Helper

(defun cpp-template--setup-keys ()
  "Internal function to set up key bindings in c++-mode."
  (local-set-key (kbd "C-c t p") #'cpp-template-new-project)
  (local-set-key (kbd "C-c t c") #'cpp-template-new-class)
  (local-set-key (kbd "C-c t h") #'cpp-template-new-header-only-class)
  (local-set-key (kbd "C-c t m") #'cpp-template-insert-method)
  (local-set-key (kbd "C-c t g") #'cpp-template-insert-getter-setter)
  (local-set-key (kbd "C-c t s") #'cpp-template-insert-singleton-pattern)
  (local-set-key (kbd "C-c t r") #'cpp-template-insert-smart-ptr-typedef)
  (local-set-key (kbd "C-c t i") #'cpp-template-insert-pimpl-pattern)
  (local-set-key (kbd "C-c t o") #'cpp-template-organize-current-file)
  (local-set-key (kbd "C-c t O") #'cpp-template-organize-all-files))

;;;###autoload
(defun cpp-template-setup-keybindings ()
  "Set up suggested key bindings for C++ templates.
Call this from your Doom config.el."
  (add-hook 'c++-mode-hook #'cpp-template--setup-keys)
  (message "C++ template keybindings configured!"))

(provide 'cpp-templates)
;;; cpp-templates.el ends here
