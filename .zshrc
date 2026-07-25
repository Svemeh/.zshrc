# Remove any old aliases that might conflict
unalias cls la cla getSuffix c cRun cAssembly killPort 2>/dev/null

# Clear terminal and ls()
cls() {clear; ls $1 $2}

# list all files in directory
#
# what each paramter does:
# -l: Long format, showing permissions, owner, size, and modification date.
# -a: Lists all files, including hidden files
# -F: Appends a symbol to each name indicating file type (e.g., / for directory, * for executable).
# -G: Enables colored output for different file types.
# -h: (Used with -l) Displays file sizes in human-readable format (KB, MB, GB).
la() {ls -laFGh $1 $2}

# Clear terminal and la()
cla() { clear; la $1 $2}

# Echos the file suffix. Used to determine file type.
getSuffix() {
  local file="$1"
  [[ "$file" == *.* ]] && echo "${file##*.}"
}

# Compile a C or C++ file into an executable
# @see get_ext()
c() {
  local filename="$1"
  if [[ -z "$filename" ]]; then
    echo "usage: c <file.c/cpp>"
    return 2
  fi

  local basename="${filename%.*}"
  suffix=$(getSuffix "$filename")

  case "$suffix" in
    c)
      gcc -Wall -o "$basename" "$filename"
      ;;
    cpp|cc|cxx)
      g++ -Wall -o "$basename" "$filename"
      ;;
    *)
      echo "given file type is not C or C++"
      ;;
  esac
}

# Compile a C or C++ file and immediately run the program
# @see c()
cRun() {
  local filename="$1"
  if [[ -z "$filename" ]]; then
    echo "usage: cRun <file.c>"
    return 2
  fi

  local basename="${filename%.*}"
  c "$filename" && "./$basename"
}

# Compile to assembly, show it, and ask whether to save
cAssembly() {
  local filename="$1"
  if [[ -z "$filename" ]]; then
    echo "usage: cAssembly <file.c>"
    return 2
  fi

  local basename="${filename%.*}"

  # compile to assembly
  if ! gcc -fno-asynchronous-unwind-tables -S "$filename" -o "$basename.s"; then
    echo "compile failed"
    return 1
  fi

  # display the assembly code
  cat "$basename.s"

  # prompt user to keep or delete file
  read "ans?do you wish to save assembly file? [y/N]: "

  if [[ "$ans" == [Yy] ]]; then
    echo "file saved as: $PWD/$basename.s"
  else
    rm -f "$basename.s"
    echo "discarded: $basename.s"
  fi
}

# kill a process by port used
killPort() {
  if [[ -z $1 ]]; then
    echo "Usage: killPort <port>"
    return 1
  fi

  local -a pids
  pids=($(lsof -ti :"$1"))

  if (( ${#pids} == 0 )); then
    echo "No process found on port $1"
    return
  fi

  echo "Killing PID(s): ${pids[*]}"
  kill -9 "${pids[@]}"
}
