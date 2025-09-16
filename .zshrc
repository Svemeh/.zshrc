# Remove any old aliases that might conflict
unalias c cRun cAssembly 2>/dev/null

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

  # display the assembly
  cat "$basename.s"

  # zsh prompt style (bash's read -p doesn't work)
  read "ans?do you wish to save assembly file? [y/N]: "

  if [[ "$ans" == [Yy] ]]; then
    echo "file saved as: $PWD/$basename.s"
  else
    rm -f "$basename.s"
    echo "discarded: $basename.s"
  fi
}

