# Abakos Tzilmiztli

Assembly language project for computer structures.
For further information please read [PDF manual](./AbakosTzilmiztli.pdf) (spanish only).

Jaime Hernandez. FI, UNAM. 2010
___

## Spanish version

Abakos Tzilmiztli es un programa que simula el funcionamiento de una calculadora científica de punto flotante mediante comandos.

### Características

- Almacena un stack de operandos de punto flotante.
- Permite operaciones unarias y binarias, aritméticas y lógicas sobre el stack, mediante comandos mnemonicos.

### Ensamblado y enlace

Para obtener ejecutable:
Ligar el objeto abakos.obj con la biblioteca liakas.lib
...>tlink abakos,,,liakas

Se obtendra abakos.exe

O bien:

1. ensamblar abakos.asm
...>tasm abakos
2. ensamblar lichanat.asm
...>tasm lichanat
3. adjuntar procesos a biblioteca
...>tlib /e liakas+lichanat.obj
4. ligar objeto abakos.obj con biblioteca
...>tlink abakos,,,liakas

Se obtendra abakos.exe

### Manual

Para mayor informacion sobre el programa, consultar el manual en el archivo [AbakosTzilmiztli.pdf](./AbakosTzilmiztli.pdf).

### Créditos

Jaime Hernández Vázquez
Facultad de Ingenieria UNAM

Para ensamblar se utilizó:
Turbo Assembler Version 4.1 (c) Borland International
Para enlazar se usó:
Turbo Link Version 7.1.30.1. (c) Borland International
Para administrar bibliotecas:
TLIB 4.00 (c) Borland International
