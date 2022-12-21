#!/bin/bash

echo "Каталоги:"
ls -la | grep "^d"
echo "Обычные файлы:"
ls -la | grep "^-"
echo "Символьные ссылки:"
ls -la | grep "^l"
echo "Символьные устройства:"
ls -la | grep "^c"
echo "Блочные устройства:"
ls -la | grep "^b"
