# quantum_emulator

A quantum computer emulator

## Description

This is a dart package that includes a simple quantum simulator.

Rather than using matrices, this package takes advantage of the fact
that single qubit gates can be broken down to how states interact
in sets of two. For example suppose you have two qubits in a full super 
position, `|a> = 1/2|01> + 1/2|10> + 1/2 |11> + 1/2|00>`. Now when you 
apply a single qubit gate, `G`, to the first qubit of `|a>` the result 
can be broken down mathematically to applying `G` to 
`1/2|01> + 1/2|11>` and `1/2|10> + 1/2|00>` and the resulting pieces do not interact. That is, `G(1/2|01>)` and `G(1/2|11>)` are both 
guaranteed to be linear combinations of `|01>` and `|11>`.

With this in mind the function 
`indexes(target, length, controls, anticontrols)` returns an 
iterator over pairs of coefficients, one for the "zero" state and
one for the "one" state (`|01>` and `|11>` respectively in the above 
example).
Then each single qubit operator is just a function that takes pairs
and returns their new values. While this process is still `O(2^n)`, 
where `n` is the number of qubits, it is still significantly faster
than matrix multiplication, which would be `O(2^{2n})`). It is also
easier to reason about, as operators can be defined simply as their
action on a single qubit.
It also produces much less complicated code, as building the 
matrices can be incredibly complicated.
This is significantly faster than matrix multiplication.
