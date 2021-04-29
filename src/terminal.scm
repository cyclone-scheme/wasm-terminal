(import (scheme base) 
        (scheme read) 
        (scheme write) 
        (scheme eval) 
        (srfi 18))

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
        (close-port fp))))
  (thread-sleep! 0.1)
  (loop)))

(loop)

