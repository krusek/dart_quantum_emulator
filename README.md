# quantum_emulator

A quantum computer emulator

## Description

This is a dart package that includes a simple quantum simulator. This 
project is mainly my experiment with the following ideas that I had
while thinking about quantum computing.

## Single Qubit gates

In classical computation, `NAND` is a universal gate. That is, all
computation could be created with a collection of correctly applied
`NAND` gates. Similary there are a collection of single qubit gates
that together can act as a collection of universal gates. I won't 
explain which gates can be used, but the important part is that they
are single qubit gates along with controlled versions of those gates.
As a matter of fact, the most famous algorithms are written in terms
of these simple gates.

A common way to explain quantum computing is in terms of matrices.
This can be good for learning how it works but quickly becomes
unweildy and confusing as more qubits are added.

Rather than using matrices, this package takes advantage of the fact
that single qubit gates and their controlled versions can be broken down to how bases interact
in sets of two. 
For example suppose you have two qubits in a full super 
position, `|a> = 1/2|01> + 1/2|10> + 1/2 |11> + 1/2|00>`. Now when you 
apply a single qubit gate, `G`, to the first qubit of `|a>` the result 
can be broken down mathematically to applying `G` to 
`1/2|01> + 1/2|11>` and `1/2|10> + 1/2|00>` and the resulting pieces do not interact. That is, `G(1/2|01>)` and `G(1/2|11>)` are both 
guaranteed to be linear combinations of `|01>` and `|11>`. Not only that but the interaction is independant of the second qubit. It just depends on the coefficient on the "zero" piece, `|01>` and the 
coefficient on the "one" piece, `|11>`.

With this in mind the function 
`indexes(target, length, controls, anticontrols)` returns an 
iterator over pairs of coefficients, one for the "zero" state and
one for the "one" state (`|01>` and `|11>` respectively in the above 
example).
Then each single qubit operator is just a function that takes pairs of
coefficients and returns their new values. Furthermore the controlled 
versions just restrict which pairs are operated on, which means the
`indexes` function just returns fewer pairs.

In this framework the Hadamard operator, `H`,  and all the Pauli gates
are defined on a single line. It also makes it very clear _what_ they
do. For example `H` is simple defined as:
```dart
final Operator H = (input) => ComplexTuple(zero: (input.zero + input.one) / sqrt(2.0), one: (input.zero - input.one) / sqrt(2.0));
```

While this process is still `O(2^n)`, 
where `n` is the number of qubits, it is still significantly faster
than matrix multiplication, which would be `O(2^{2n})`). It is also
easier to reason about, as operators can be defined simply as their
action on a single qubit.
It also produces much less complicated code, as building the 
matrices can be incredibly complicated.
This is significantly faster than matrix multiplication.
