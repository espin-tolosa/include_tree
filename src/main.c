#define _GNU_SOURCE
#include <stdio.h>
#include <dlfcn.h>
#include <stdlib.h>
#include <fcntl.h>
#include <errno.h>
#include <string.h>
#include <sys/stat.h>
#include <gtk/gtk.h>


//typedef void * (*malloc_def) (size_t);
//
//void* malloc(size_t s)
//{
//  malloc_def sysmalloc = (malloc_def) dlsym( RTLD_NEXT, "malloc" );
//  printf("Allocating %lu bytes\n", s);
//  void *result = sysmalloc(s);
//  memset(result, 0xCD, s);
//  return sysmalloc(s);
//}
//



static void* (*real_malloc)(size_t)=NULL;

static void mtrace_init(void)
{
    real_malloc = dlsym(RTLD_NEXT, "malloc");
    if (NULL == real_malloc) {
        fprintf(stderr, "Error in `dlsym`: %s\n", dlerror());
    }
}

void *malloc(size_t size)
{
    if(real_malloc==NULL) {
        mtrace_init();
    }

    void *p = NULL;
    fprintf(stderr, "malloc(%d) = ", size);
    p = real_malloc(size);
    fprintf(stderr, "%p\n", p);
    return p;
}



static void ditlib(char* buffer, char **result)
{
  const char *msg = "Hello";
  char **test = &msg;
  const char *success = "OK";
  const char *fail    = "KO";
  //example of fail condition
  if(buffer != "010")
  {
    *result = fail;
  }

  //reach this point means success
  *result = success;
}

char buffer[] = "010";

typedef struct {
  char *src;
  char *dst;
} IO_Address;

IO_Address io_address = {
  .src =  buffer,
  .dst = NULL,
};

static void print_verify (GtkWidget *widget, gpointer data)
{
  char *buffer = ((IO_Address*)data)->src;
  printf("Verify Data from address: %s\n", buffer);

  ditlib(buffer, &((IO_Address*)data)->dst);
}

static void print_result (GtkWidget *widget, gpointer data)
{
  char *dst = ((IO_Address*)data)->dst;
  if(dst == NULL)
  {
    printf("Data isn't processed, press Run\n");
    return;
  }

  printf("Data is verified: %s\n", dst);
}

static void dit_fopen(char *filename);
static off_t dit_fsize(char *filename);
static void dit_fread(char *filename, char *buffer);

static void open_dialog(GtkWidget* button, gpointer window)
{
  GtkWidget *const dialog = gtk_file_chooser_dialog_new(
                              "Chosse a file",
                              GTK_WINDOW(window),
                              GTK_FILE_CHOOSER_ACTION_OPEN,
                              GTK_STOCK_OK,
                              GTK_RESPONSE_OK,
                              GTK_STOCK_CANCEL,
                              GTK_RESPONSE_CANCEL,
                              NULL);

  gtk_widget_show_all(dialog);
  gtk_file_chooser_set_current_folder(GTK_FILE_CHOOSER(dialog),"./");
  gint resp = gtk_dialog_run(GTK_DIALOG(dialog));
  if(resp == GTK_RESPONSE_OK) {
    char *filename = gtk_file_chooser_get_filename(GTK_FILE_CHOOSER(dialog));
    printf("File: %s\n", filename);

    off_t file_size = dit_fsize(filename);
    char *const buffer = malloc(file_size);

    dit_fread(filename, buffer);

    free(buffer);
    g_free(filename);
  }
  else {
    g_print("You pressed Cancel\n");
  }

  gtk_widget_destroy(dialog);
}

static void dit_fread(char *filename, char *buffer)
{
  FILE *fp = fopen(filename, "r");

  int i = 0;
  while(1)
  {
    int c = fgetc(fp);


    if(feof(fp))
    {
      break;
    }

    buffer[i++] = c;
  }

  fclose(fp);
}

static off_t dit_fsize(char *filename)
{
  FILE* fp;
  int fd;
  off_t file_size;
  char *buffer;
  struct stat st;
  fd = open(filename, O_RDONLY);
  if (fd == -1) {
    printf("FD == -1\n");
  }
  fp = fdopen(fd, "r");
  if (fp == NULL) {
    printf("FP == null\n");
  }
  if ((fstat(fd, &st) != 0) || (!S_ISREG(st.st_mode))) {
    printf("(fstat(fd, &st) != 0) || (!S_ISREG(st.st_mode))\n");
  }
  if (fseeko(fp, 0 , SEEK_END) != 0) {
    printf("fseeko(fp, 0, SEEK_END) != 0\n");
  }
  file_size = ftello(fp);
  if (file_size == -1) {
    printf("file_size == -1\n");
  }

  printf("File size: %lu\n", file_size);

  return file_size;
}

static void activate (GtkApplication *app, gpointer user_data)
{
  GtkWidget *window;
  GtkWidget *grid;
  GtkWidget *button;

  window = gtk_application_window_new (app);
  gtk_window_set_title (GTK_WINDOW (window), "Window");
  gtk_window_set_default_size (GTK_WINDOW (window), 400, 200);
  gtk_container_set_border_width (GTK_CONTAINER (window), 10);

  grid = gtk_grid_new ();

  gtk_container_add (GTK_CONTAINER (window), grid);

  button = gtk_button_new_with_label ("Load File");
  g_signal_connect (button, "clicked", G_CALLBACK (open_dialog), NULL);

  gtk_grid_attach (GTK_GRID (grid), button, 0, 0, 1, 1);

  button = gtk_button_new_with_label ("Run DIT");
  g_signal_connect (button, "clicked", G_CALLBACK (print_verify), &io_address);

  gtk_grid_attach (GTK_GRID (grid), button, 0, 1, 1, 1);

  button = gtk_button_new_with_label ("Save & Exit");
  g_signal_connect (button, "clicked", G_CALLBACK (print_result), &io_address);

  gtk_grid_attach (GTK_GRID (grid), button, 0, 3, 1, 1);

  gtk_widget_show_all (window);

}

int main (int argc, char **argv)
{
  GtkApplication *const app =
  gtk_application_new ("shm.dit", G_APPLICATION_FLAGS_NONE);

  g_signal_connect (app, "activate", G_CALLBACK (activate), NULL);

  const int status = g_application_run (G_APPLICATION (app), argc, argv);

  g_object_unref (app);

  return status;
}

