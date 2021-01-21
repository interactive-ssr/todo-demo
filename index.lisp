(defpackage todo-demo
  (:use #:cl #:markup)
  (:import-from #:hunchentoot
                start-session
                session-value
                easy-acceptor)
  (:import-from #:hunchenissr
                define-easy-handler
                *id*
                *ws-port*
                start
                stop))
(in-package #:todo-demo)
(markup:enable-reader)

(define-easy-handler (todo :uri "/todo")
    (;; GET parameter names go here
     add-new-task new-task check)
  (start-session)
  (let (;; define local variables here
        (todos (session-value 'todos))
        ;; calculate if we are to add a new task
        (adding-new-task
          (and add-new-task new-task
               (string= add-new-task "add")
               (not (str:emptyp
                     (str:trim new-task))))))
    ;; add new task
    (when adding-new-task
      (setf todos (append todos (list (list nil new-task)))))
    ;; toggle checks
    (when (and check (not (str:emptyp check)))
      (let* ((check (parse-integer check))
             (todo (elt todos check)))
        (setf (first todo)
              (not (first todo)))))
    ;; save todo list in session
    (setf (session-value 'todos) todos)
    (write-html
     <html>
       <head>
         <script src="/issr.js"></script>
         <script noupdate="t">
           ,(format nil "setup(~a,~a)" *id* *ws-port*)
         </script>
         <title>,(progn "To Do List | ISSR")</title>
       </head>
       <body>
         <h1>To Do List</h1>
         <ul>
           ,@(loop for todo in todos
                   for index from 0 below (length todos)
                   collect
                   <li>
                     <button action="check"
                             value=index
                             onclick="rr(this)">
                       ,(if (first todo)
                            "Mark Not Done"
                            "Mark Done")
                     </button>
                     ,(if (first todo)
                          <strike>,(second todo)</strike>
                          <span>,(second todo)</span>)
                   </li>)
         </ul>
         <!-- The value attribute is to remove the content when
              a new task was just added. The update attribute is
              to ensure that the value of empty string is updated
              on the client. -->
         <input name="new-task"
                value=(when adding-new-task
                        "")
                update=adding-new-task
                placeholder="New Task"/>
         <button action="add-new-task"
                 value="add"
                 onclick="rr(this)">
           Add
         </button>
       </body>
     </html>)))

(define-easy-handler (todo-tutorial :uri "/todo-tutorial")
    (theme)
    <php:tutorial title="To Do List Tutorial | ISSR"
                  body-file="tutorial-body.html"
                  theme=theme />)
