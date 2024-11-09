# Summary of Behavior

  ## Terminal 1 (Writing to the Pipe):
        The cat > mypipe command waits for keyboard input. It writes whatever you type into the pipe.
        It continues waiting for input (i.e., more data) until Ctrl+D is pressed, signaling the end of input.

  ## Terminal 2 (Reading from the Pipe):
        The cat < mypipe command waits for data to appear in the pipe. It blocks until something is written into the pipe.
        Once data is available, cat in Terminal 2 reads it and displays it immediately.
        If no more data is available, it waits until more data is written or the pipe is closed.

# Important 
   When cat is writing (cat > mypipe in Terminal 1):
	-  cat is waiting for user input (from the keyboard).
	- Once Ctrl+D is pressed, the process will finish, and Terminal 1 will exit.

   When cat is reading (cat < mypipe in Terminal 2):
	- cat is waiting for data to be written to the pipe.
	- It blocks until it receives data, then it displays the data and exits when all data has been read. 
