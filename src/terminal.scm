(import (scheme base) 
        (scheme read) 
        (scheme write) 
        (scheme eval) 
        (srfi 18))

;(include-c-header "cyclone/types.h")
(include-c-header "<emscripten.h>")
(include-c-header "ck-polyfill.h")
(include-c-header "terminal.h")

(define *site-url* "http://justinethier.github.io/cyclone")
(define (help . opts)
  (cond
    (else
      (display (string-append "
Type (help) to see this menu.
Type (help object) to find API documentation for object

Cyclone
Website: " *site-url* "
User Manual: " *site-url* "/docs/User-Manual
API Documentation: " *site-url* "/docs/API
Forum: https://github.com/justinethier/cyclone/discussions
Report a Bug: https://github.com/justinethier/cyclone/issues

Other Resources
R7RS Scheme Language Specification: " *site-url* "/docs/r7rs.pdf

")))))

;(define-c help2
;  "(void *data, object _, int argc, object *args)"
;  " object k = args[0]; 
;    __glo_help(data, NULL, argc, args);
;  ")

(define-c get-input
  "(void *data, object _, int argc, object *args)"
  " object k = args[0]; 
    /* TODO: use mutex to lock glo_sexp */
    char *s = glo_sexp;
    glo_sexp = NULL;
    /* TODO: unlock */
  
    if (s != NULL) {
      make_utf8_string(data, str, s);
      free(s);
      return_closcall1(data, k, &str); 
    } else {
      return_closcall1(data, k, boolean_f);
    } ")

(define-c ready-for-more-input
  "(void *data, object _, int argc, object *args)"
  " object k = args[0]; 
    MAIN_THREAD_ASYNC_EM_ASM(
      readyForNextCommand();
    );
    return_closcall1(data, k, boolean_f);
  ")

(define (loop)
  (with-handler                                                              
    (lambda (obj)                                                            
      (display "Error: ")                                                    
      (cond                                                                  
        ((error-object? obj)                                                 
         (display (error-object-message obj))                                
         (if (not (null? (error-object-irritants obj)))                      
             (display ": "))                                                 
         (for-each                                                           
           (lambda (o)                                                       
             (write o)                                                       
             (display " "))                                                  
           (error-object-irritants obj)))                                    
        ((pair? obj)                                                         
         (when (string? (car obj))                                           
           (display (car obj))                                               
           (if (not (null? (cdr obj)))                                       
               (display ": "))                                               
           (set! obj (cdr obj)))                                             
         (for-each                                                           
           (lambda (o)                                                       
             (write o)                                                       
             (display " "))                                                  
           obj))                                                             
        (else                                                                
          (display obj)))                                                    
      (newline)                                                              
      (ready-for-more-input)
      (loop))
  (let ((str (get-input)))
    (when str
      (let* ((fp (open-input-string str))
             (sexp-lis (read-all fp))) 
        (for-each 
          (lambda (sexp)
            (let ((obj (eval sexp)))
              (write obj)
              (newline)))
          sexp-lis)
        (close-port fp))
      (ready-for-more-input)))
  (thread-sleep! 0.1)
  (loop)))

(help)
(loop)

