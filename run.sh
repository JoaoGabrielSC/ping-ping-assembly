#!/bin/bash

ASM_DIR="/Users/user/frasm"

if [ -z "$1" ]; then
  echo "Uso: $0 <NOME_RAW_DO_PROGRAMA>"
  echo "Exemplo: $0 EP1"
  exit 1
fi

INPUT="$1"

PROGRAM_WITHOUT_EXT="${INPUT%%.*}"

if [[ "$INPUT" != "$PROGRAM_WITHOUT_EXT" ]]; then
  echo "Aviso: você deve fornecer o nome do programa sem extensão."
  echo "Aviso: removendo extensão de '$INPUT'. Usando '$PROGRAM_WITHOUT_EXT'."
fi

dosbox -c "mount c $ASM_DIR" \
       -c "c:" \
       -c "nasm16 -f obj -o $PROGRAM_WITHOUT_EXT.OBJ -l $PROGRAM_WITHOUT_EXT.LST $PROGRAM_WITHOUT_EXT.ASM" \
       -c "freelink $PROGRAM_WITHOUT_EXT.OBJ" \
       -c "$PROGRAM_WITHOUT_EXT.EXE" \
       -c "exit"
