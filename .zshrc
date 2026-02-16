unalias nvim cls la cla c cRun cAssembly 2>/dev/null

# Open NeoVim -- might be a better method for this xd
nvim() { ~/nvim-macos-arm64/bin/nvim $1 }

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

# Compile a C file into an executable
c() {
  local filename="$1"
  if [[ -z "$filename" ]]; then
    echo "usage: c <file.c>"
    return 2
  fi

  local basename="${filename%.*}"
  gcc -Wall -o "$basename" "$filename"
}

# Compile a C file and immediately run the program
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
