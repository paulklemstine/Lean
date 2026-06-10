# The Inspectors Who Never Look at the Whole Thing

## How mathematicians proved you can verify enormous computations by checking almost nothing

Imagine you hire two accountants to multiply together two enormous spreadsheets — tables of numbers with millions of rows and columns. They hand you the result: another colossal spreadsheet. How do you know they got it right?

The brute-force answer is obvious: redo the multiplication yourself. But that defeats the purpose of hiring the accountants. It would take the same astronomical amount of time — for square tables with *n* rows, multiplying them requires roughly *n³* arithmetic operations. For a million-row spreadsheet, that is a quintillion calculations. Even a fast computer would sweat.

In 1977, a Latvian-born mathematician named Rūsiņš Freivalds discovered something that still feels like a magic trick. He showed that you can verify the accountants' work — with near-perfect confidence — using only *n²* operations. Not by redoing the multiplication, but by asking the spreadsheet a single random question.

The trick is breathtakingly simple. Pick a random column of ones and zeros. Multiply the alleged answer by this column. Separately, multiply the two original spreadsheets by the same column, one at a time. If the results match, the answer is probably correct. If they don't, you've caught an error.

The mathematics behind this "probably" is what makes the trick profound. Freivalds proved that if the answer is wrong — if even a single entry is off — then a randomly chosen test column will catch the error at least half the time. Run the test twenty times with independent random columns, and the probability of a wrong answer slipping through drops below one in a million.

This is not an approximation or a heuristic. It is a theorem, as rigorous as the Pythagorean theorem, and it has now been machine-verified to the highest standard of mathematical certainty.

## The engine behind the trick

What makes Freivalds' trick work is a beautiful piece of geometry hiding inside finite arithmetic.

Think of the error — the difference between the claimed answer and the true product — as a grid of numbers. If the answer is wrong, at least one row of this grid is nonzero. That nonzero row defines a constraint: a single linear equation in *n* unknowns.

Now here is the key insight. The set of test columns that *fail to detect* this error — the ones that give the same result whether the answer is right or wrong — forms a flat surface (a hyperplane) in an *n*-dimensional space. This surface contains exactly one-*q*th of all possible test columns, where *q* is the size of the number system being used.

For ordinary binary vectors (zeros and ones), *q* = 2, so half of all test columns will catch any error. For larger number systems, the detection rate climbs even higher. Over a system with 101 possible values, fewer than 1% of random probes will miss an error.

This is not a coincidence. It is a consequence of a deep fact about linear algebra over finite fields: a nonzero linear equation in *n* unknowns over a field of size *q* has exactly *q*^(*n*−1) solutions. The zero set is always a hyperplane — big enough to be interesting, but too small to hide from random sampling.

## Breaking big problems into small ones

Freivalds' trick handles one kind of verification. But modern computation involves structure — not just flat tables of numbers, but organized, modular systems where different parts are computed independently.

Think of a large computation broken into blocks — like a factory where different workshops handle different components. A block-diagonal matrix is the mathematical version of this: it has active entries only along the diagonal, in separate square patches, with zeros everywhere else.

For such structured computations, a different verification principle applies. If the global computation is wrong, then at least one block must be wrong. And conversely, if every block is correct, the whole thing is correct. This is the **gluing principle**: local correctness assembles into global correctness, deterministically, with no randomness required.

This sounds almost tautological, but its mathematical formalization has surprising power. It means you can distribute verification across multiple independent checkers, each examining only its own block. The total work is proportional to the sum of the cubes of the block sizes — which can be dramatically less than the cube of the total size.

For a matrix made of *k* blocks each of size *n/k*, the savings are a factor of *k²*. For a thousand blocks, that is a million-fold speedup in verification.

## The robustness revolution

Both the probabilistic trick and the structural decomposition assume exact arithmetic — every number is perfectly precise. But real computation is messy. Floating-point numbers have rounding errors. Signals have noise. Measurements have uncertainty.

This is where a third pillar of verification enters: **robustness theory**. The key theorem is surprisingly clean: if a computation has any error at all, then a carefully chosen test input — one with all components bounded by 1 in absolute value — will produce a nonzero output discrepancy. The error cannot hide from bounded probes.

The proof is constructive: if some entry of the error matrix is nonzero, the corresponding standard basis vector (all zeros except a single one) will detect it. This is the mathematical equivalent of pressing each key on a piano to find the broken one.

What makes this truly powerful is the connection to **tropical mathematics** — a strange and beautiful variant of arithmetic where addition is replaced by taking maximums and multiplication is replaced by addition. In tropical arithmetic, the bound on output error takes a particularly clean form:

*The maximum output discrepancy is at most n times the maximum entry error times the maximum input magnitude.*

This bound composes through layers. For a chain of *L* matrix operations, the error accumulates at most polynomially — and the tropical bound gives an explicit, computable certificate for how much.

## Three pillars, one theory

The real breakthrough is not any single theorem but their unification. These three verification methods — probabilistic probing, structural decomposition, and robustness bounds — are not independent techniques. They are three views of the same mathematical object.

When a computation fails, all three methods detect it simultaneously:

- **Structurally**, some component is wrong. You can find it by examining blocks.
- **Probabilistically**, a random probe catches the error with high probability.
- **Robustly**, a bounded-norm witness produces measurable output discrepancy.

This trichotomy has been formally verified as a single theorem. It says: the three detection mechanisms are not alternatives but reinforcing views. Any failure is simultaneously structural, probabilistic, and robustly detectable.

The mathematical structure behind this unification is reminiscent of a concept from geometry called a *sheaf* — a system where local data patches together consistently into global information. In verification theory, local certificates (one per block, or one per random probe) assemble into global guarantees. The failure of this assembly — when local checks cannot glue into a global certificate — is precisely what indicates an error.

## Why this matters now

The timing of this mathematical unification is not accidental. We live in an era of computation at unprecedented scale. Large language models multiply matrices with billions of entries. Distributed computing clusters split computations across thousands of machines. Scientific simulations run for months on supercomputers.

In each case, the same question arises: how do you know the computation was correct?

For artificial intelligence, the stakes are particularly high. A neural network is, mathematically, a sequence of matrix-vector multiplications interleaved with simple nonlinear functions. If the matrix multiplication is wrong — due to hardware errors, software bugs, or adversarial manipulation — the network's outputs cannot be trusted.

The theory of decomposable verification offers a path forward. A neural network with block-diagonal structure (as found in mixture-of-experts architectures, modular networks, and many practical designs) can be verified block by block. Each block's computation can be checked probabilistically with Freivalds-style probes. And the robustness bounds guarantee that even approximate verification — with floating-point arithmetic — gives meaningful certificates.

The verification cost scales with the square of the matrix size, not the cube. For a network layer with a million parameters, this is the difference between a feasible check and an impossible one.

## The deeper story

Behind these specific theorems lies a more profound mathematical narrative. For most of the history of mathematics, there were two ways to establish truth: prove it rigorously (slow, certain) or test it empirically (fast, uncertain).

What Freivalds and his intellectual descendants discovered is a third way: prove it rigorously that testing works. The randomized check is not a heuristic — it comes with a mathematical guarantee. The guarantee is not approximate — it is an exact bound on the probability of error. And the bound is not conjectural — it has been verified by machine to the highest standards of mathematical proof.

This fusion of certainty and efficiency is one of the great insights of modern mathematics. It says that randomness is not the enemy of rigor but its ally. A random probe can be more informative than a deterministic one, and the mathematical proof of this fact is itself completely deterministic.

The decomposable verification framework extends this insight from single computations to structured, compositional systems. It says that the power of randomized checking, structural decomposition, and quantitative robustness are not separate phenomena but facets of one geometric reality: the zero set of a nonzero linear form is always a hyperplane, and hyperplanes are always detectable.

In the landscape of ideas, this is a small mountain with a surprisingly large view. From its peak, you can see connections to coding theory, cryptography, complexity theory, numerical analysis, and the emerging science of trustworthy artificial intelligence. All of these fields, in their different ways, are asking the same question: how can you be sure, quickly and cheaply, that a computation got the right answer?

The mathematics says: ask it a random question. If the answer is wrong, the question will reveal it. And if you organize the questions right — block by block, layer by layer, with tropical bounds keeping the errors in check — you can verify almost anything by examining almost nothing.

That is the paradox at the heart of modern verification theory, and it is now a mathematical fact.
