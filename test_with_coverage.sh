#/usr/bin/bash

flutter test --coverage
genhtml coverage/lcov.info --output-directory=coverage/html