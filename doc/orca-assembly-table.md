ORCA ASSEMBLY INSTRUCTION TABLE
===============================

| Kind                          | Command                                                                           | Note  |
| ----------------------------- | --------------------------------------------------------------------------------- | ----- |
| Static String Allocation      | SSA (address) address                                                             | SSA   |
| Static Number Allocation      | SNA (address) address                                                             | SNA   |
| Static Array Allocation       | SAA (address) address                                                             | SAA   |
| Dynamic String Allocation     | DSA (register) address                                                            | DSA   |
| Dynamic Number Allocation     | DNA (register) address                                                            | DNA   |
| Dynamic Array Allocation      | DAA (register) address                                                            | DAA   |
| Numeric Data Writing          | NDW (address) address, (value) number                                             | NDW   |
| String Data Writing           | SDW (address) address, (value) string                                             | SDW   |
| Reference Writing             | RDW (address) address, (mem_addr) target                                          | RDW   |
| Element Selection by Index    | ESI (register) register, (address) array, (value) index                           | ESI   |
| Element Addition              | EAD (address) array, (address) address                                            | EAD   |
| Operation                     | OPR (register) register, (value) operator, (value) operand1, (value)operand2 ...  | OPR   |
| Stack Push                    | PSH (value) data                                                                  | PSH   |
| Stack Pop                     | POP (register) register                                                           | POP   |
| Pointer Jump                  | JMP (value) condition, (value) pointer                                            | JMP   |
| Execution with Return         | EXR (register) register, (value) executor, (value) args...                        | EXR   |
| Execution without Return      | EXE (value) executor, (value) args...                                             | EXE   |
| Termination                   | END                                                                               | END   |
