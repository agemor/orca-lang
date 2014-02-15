ORCA ASSEMBLY INSTRUCTION TABLE
===============================
indicator: register index
, value: actual value

| Kind                          | Command                                                                           | Note  |
| ----------------------------- | --------------------------------------------------------------------------------- | ----- |
| Static String Allocation      | SSA (value) address                                                             | SSA   |
| Static Number Allocation      | SNA (value) address                                                             | SNA   |
| Static Array Allocation       | SAA (value) address                                                           | SAA   |
| Dynamic String Allocation     | DSA (indicator) address                                                            | DSA   |
| Dynamic Number Allocation     | DNA (indicator) address                                                            | DNA   |
| Dynamic Array Allocation      | DAA (indicator) address                                                            | DAA   |
| Numeric Data Writing          | NDW (value) address, (value) number                                             | NDW   |
| String Data Writing           | SDW (value) address, (value) string                                             | SDW   |
| Reference Writing             | RDW (value) address, (value) target                                          | RDW   |
| Element Selection by Index    | ESI (indicator) register, (value) array, (value) index                           | ESI   |
| Element Addition              | EAD (value) array, (value) index, (value) address                                            | EAD   |
| Operation                     | OPR (indicator) register, (value) operator, (value) operand1, (value)operand2 ...  | OPR   |
| Stack Push                    | PSH (value) data                                                                  | PSH   |
| Stack Pop                     | POP (indicator) register                                                           | POP   |
| Pointer Jump                  | JMP (value) condition, (value) pointer                                            | JMP   |
| Execution with Return         | EXR (indicator) register, (value) executor, (value) args...                        | EXR   |
| Execution without Return      | EXE (value) executor, (value) args...                                             | EXE   |
| Termination                   | END                                                                               | END   |
