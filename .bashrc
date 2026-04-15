# Remove any old aliases that might conflict
unalias nvim cls la cla c cRun cAssembly killPort 2>/dev/null

# Open NeoVim
nvim() {
  ~/nvim-macos-arm64/bin/nvim "$1"
}

# Clear terminal and list files
cls() {
  clear
  ls "$1" "$2"
}

# list all files in directory
la() {
  ls -laFGh "$1" "$2"
}

# Clear terminal and run la()
cla() {
  clear
  la "$1" "$2"
}

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

# Compile and run
cRun() {
  local filename="$1"

  if [[ -z "$filename" ]]; then
    echo "usage: cRun <file.c>"
    return 2
  fi

  local basename="${filename%.*}"
  c "$filename" && "./$basename"
}

# Compile to assembly, show it, optionally save
cAssembly() {
  local filename="$1"

  if [[ -z "$filename" ]]; then
    echo "usage: cAssembly <file.c>"
    return 2
  fi

  local basename="${filename%.*}"

  if ! gcc -fno-asynchronous-unwind-tables -S "$filename" -o "$basename.s"; then
    echo "compile failed"
    return 1
  fi

  cat "$basename.s"

  read -p "do you wish to save assembly file? [y/N]: " ans

  if [[ "$ans" == [Yy] ]]; then
    echo "file saved as: $PWD/$basename.s"
  else
    rm -f "$basename.s"
    echo "discarded: $basename.s"
  fi
}

# Kill process by port
killPort() {
  if [ -z "$1" ]; then
    echo "Usage: killPort <port>"
    return 1
  fi

  pid=$(lsof -ti :$1)

  if [ -z "$pid" ]; then
    echo "No process found on port $1"
  else
    echo "Killing process $pid on port $1"
    kill -9 $pid
  fi
}
