
char *glo_sexp = NULL;

EMSCRIPTEN_KEEPALIVE
void sendToEval(char *sexp) {
  char *d = malloc(strlen(sexp) + 1);
  if (d) {
    strcpy(d, sexp);
  }
// TODO: use mutex to lock glo_sexp
  glo_sexp = d;
// TODO: unlock
} 
