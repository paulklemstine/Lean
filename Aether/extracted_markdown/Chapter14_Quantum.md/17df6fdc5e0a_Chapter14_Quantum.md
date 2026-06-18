# Chapter 14: Quantum Computation

## 14.1 Computing with Physics

Every model of computation we have discussed so far is, at bottom, *classical*. Whether we
speak of Turing machines, lambda calculus, or circuits, we work with bits that are
definitively 0 or 1, and operations that are deterministic (or at most probabilistic).

But the physical world is not classical — it is quantum mechanical. Quantum systems exhibit
phenomena (superposition, entanglement, interference) that have no classical analogue. The
question of quantum computation is: can we exploit these phenomena to compute faster?

The answer, established by the work of Feynman, Deutsch, Shor, Grover, and many others, is
a qualified *yes*. Quantum computers can solve certain problems exponentially faster than
any known classical algorithm. Whether they can solve NP-complete problems efficiently
remains doubtful — but even without that, they represent a profound expansion of our
understanding of computation.

## 14.2 Qubits

The fundamental unit of quantum information is the **qubit** (quantum bit). Unlike a
classical bit, which is either 0 or 1, a qubit can be in a **superposition**:

> `|ψ⟩ = α|0⟩ + β|1⟩`

where `α, β ∈ ℂ` and `|α|² + |β|² = 1`.

When we **measure** the qubit, we get:
- `0` with probability `|α|²`
- `1` with probability `|β|²`

and the qubit collapses to the measured state. This is irreversible — measurement destroys
the superposition.

A system of `n` qubits has a state in the `2ⁿ`-dimensional complex Hilbert space:

> `|ψ⟩ = ∑_{x ∈ {0,1}ⁿ} αₓ |x⟩`

with `∑ |αₓ|² = 1`. This exponential state space is the source of quantum computing's
power — and its subtlety.

## 14.3 Quantum Gates

Quantum computation proceeds by applying **unitary transformations** (quantum gates) to
qubits. Common gates include:

**Hadamard gate** (creates superposition):
```
H|0⟩ = (|0⟩ + |1⟩)/√2
H|1⟩ = (|0⟩ - |1⟩)/√2
```

**CNOT gate** (entangles two qubits):
```
CNOT|00⟩ = |00⟩
CNOT|01⟩ = |01⟩
CNOT|10⟩ = |11⟩
CNOT|11⟩ = |10⟩
```

**Phase gate**:
```
S|0⟩ = |0⟩
S|1⟩ = i|1⟩
```

**T gate** (π/8 rotation):
```
T|0⟩ = |0⟩
T|1⟩ = e^{iπ/4}|1⟩
```

**Theorem (Universality)**. The set `{H, T, CNOT}` is **universal**: any unitary
transformation on `n` qubits can be approximated to arbitrary precision by a circuit
composed of these gates.

## 14.4 Quantum Circuits

A **quantum circuit** is a sequence of quantum gates applied to a register of qubits,
followed by measurement. The circuit model is the quantum analogue of classical Boolean
circuits.

```
|0⟩ ──H──●──── M → classical bit
         |
|0⟩ ─────X──── M → classical bit
```

This circuit creates a Bell state `(|00⟩ + |11⟩)/√2` — an *entangled* state where the
two qubits are perfectly correlated.

## 14.5 Deutsch's Algorithm

The simplest demonstration of quantum advantage is **Deutsch's algorithm** (1985). Given a
function `f : {0,1} → {0,1}`, determine whether `f` is constant (f(0) = f(1)) or balanced
(f(0) ≠ f(1)).

Classically, you must evaluate `f` twice. Quantumly, you can determine this with a *single*
query:

1. Prepare `|0⟩|1⟩`
2. Apply `H ⊗ H` to get `(|0⟩ + |1⟩)(|0⟩ - |1⟩)/2`
3. Apply the oracle `U_f|x⟩|y⟩ = |x⟩|y ⊕ f(x)⟩`
4. Apply `H` to the first qubit
5. Measure the first qubit: get `0` if constant, `1` if balanced

This extends to `n` bits: the **Deutsch–Jozsa algorithm** determines whether
`f : {0,1}ⁿ → {0,1}` is constant or balanced with a single query, while any deterministic
classical algorithm needs `2^{n-1} + 1` queries in the worst case.

## 14.6 Shor's Algorithm

The most famous quantum algorithm is **Shor's algorithm** (1994) for integer factoring:

**Theorem (Shor)**. There exists a quantum algorithm that factors an `n`-bit integer in
time `O(n³)` (with high probability).

The best known *classical* algorithm (the general number field sieve) runs in time
`exp(O(n^{1/3} (log n)^{2/3}))` — sub-exponential but super-polynomial. Shor's algorithm
is exponentially faster.

**Key Idea**: Factoring reduces to finding the *period* of the function `f(x) = aˣ mod N`.
The quantum Fourier transform (QFT) can find this period efficiently, exploiting
constructive and destructive interference of amplitude paths.

**Implications**: Shor's algorithm breaks RSA encryption, which relies on the difficulty of
factoring. This has motivated the development of **post-quantum cryptography** — encryption
schemes believed to be secure against quantum computers.

## 14.7 Grover's Algorithm

**Grover's algorithm** (1996) searches an unstructured database of `N` items in
`O(√N)` time, compared to `O(N)` classically.

More precisely, given a function `f : {0,1}ⁿ → {0,1}` with a unique `x₀` satisfying
`f(x₀) = 1`, Grover's algorithm finds `x₀` with `O(√{2ⁿ})` queries.

**Key Idea**: Start with a uniform superposition. Repeatedly apply the "Grover iterate":
1. **Oracle step**: Flip the phase of the target state `|x₀⟩`.
2. **Diffusion step**: Reflect about the average amplitude.

After `O(√N)` iterations, the amplitude of `|x₀⟩` is close to 1.

**Theorem (BBBV, 1997)**. Grover's algorithm is *optimal*: any quantum algorithm for
unstructured search requires `Ω(√N)` queries. This is a *quadratic* speedup, not
exponential.

## 14.8 BQP

**Definition**. `BQP` (Bounded-error Quantum Polynomial time) is the class of languages
decidable by a polynomial-time quantum algorithm with error probability ≤ 1/3.

**Known relationships**:
```
P ⊆ BPP ⊆ BQP ⊆ PP ⊆ PSPACE
```

- `BPP ⊆ BQP`: Quantum computers can simulate classical randomized algorithms.
- `BQP ⊆ PSPACE`: A classical computer with polynomial space can simulate a quantum
  computer (by tracking the full state vector, which has exponentially many amplitudes but
  each can be computed in polynomial space).

**The central question**: Is `BQP ⊃ BPP`? That is, can quantum computers solve problems
that classical randomized computers cannot? Shor's algorithm provides strong evidence for
"yes" (assuming factoring is classically hard), but this is unproven.

## 14.9 Quantum Error Correction

Real quantum computers are noisy — qubits decohere and gates are imperfect. **Quantum
error correction** is essential for large-scale quantum computation.

**Theorem (Threshold Theorem)**. If the error rate per gate is below a constant threshold
`p₀ > 0`, then arbitrarily long quantum computations can be performed reliably using
`O(polylog(1/ε))` overhead per gate.

Key ideas:
- **Shor's code**: Encodes 1 logical qubit in 9 physical qubits.
- **Steane code**: Uses 7 physical qubits (a CSS code based on classical Hamming codes).
- **Surface code**: A topological code that is the leading candidate for practical
  implementation, with a relatively high threshold of ~1%.

## 14.10 Quantum Supremacy and the Future

In 2019, Google's Sycamore processor performed a specific sampling task in 200 seconds
that was estimated to take a classical supercomputer ~10,000 years. This "quantum supremacy"
(or "quantum advantage") demonstration was a milestone, though the practical utility of the
specific task is limited.

The near-term future of quantum computing lies in:
- **NISQ algorithms**: Algorithms for Noisy Intermediate-Scale Quantum devices, including
  variational quantum eigensolvers (VQE) and quantum approximate optimization (QAOA).
- **Fault-tolerant quantum computing**: Building large-scale error-corrected quantum
  computers, likely decades away but the ultimate goal.
- **Quantum simulation**: Simulating quantum systems (chemistry, materials science) —
  arguably the most impactful near-term application.

For computational complexity, the deep question remains: what is the *exact* relationship
between BQP and classical complexity classes? Quantum computers seem to live in a curious
middle ground — more powerful than classical computers for some problems, but probably not
powerful enough to solve NP-complete problems efficiently.

---

*"Nature isn't classical, dammit, and if you want to make a simulation of nature, you'd
better make it quantum mechanical."*
— Richard Feynman, 1981
