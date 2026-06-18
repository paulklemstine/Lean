# Cracking Codes with Right Triangles: How Ancient Geometry Could Reshape Cybersecurity

*A new mathematical framework turns the 2,500-year-old Pythagorean theorem into a tool for breaking — and understanding — the encryption that guards your data*

---

Every time you buy something online, send a private message, or log into your bank account, your data is protected by a mathematical lock. The key to that lock? The sheer difficulty of factoring large numbers — taking a number like 391 and discovering that it equals 17 × 23. For small numbers, this is trivial. For numbers with hundreds of digits, the best algorithms known to humanity would take longer than the age of the universe.

But what if there were a shortcut hidden in the oldest theorem in mathematics?

## The Inside-Out Approach

A research team has been exploring an unconventional approach to factoring called **Inside-Out Factoring** (IOF), which maps the problem of breaking a number apart onto the geometry of right triangles — specifically, the Pythagorean triples that satisfy $a^2 + b^2 = c^2$.

The core insight is beautifully simple. Take an odd number $N$ that you want to factor. The IOF algorithm constructs a sequence of Pythagorean triples, starting with a "thin" right triangle and progressively reshaping it. At each step, it checks whether a certain geometric quantity — the even leg of the triangle — shares a common factor with $N$. When it does, you've found a factor.

Previous work established the mathematical foundations and proved that this approach works. Now, a new paper pushes into the future: twelve research directions, each formalized and proven correct by a computer.

## The 99.5% Shortcut

Perhaps the most immediately practical finding involves a clever filtering technique. In the basic IOF algorithm, you check every step of the descent for a factor — like trying every door in a long hallway. But the team proved that most of those doors can be skipped.

The trick uses **quadratic residues** — a concept from number theory that tells you which numbers can be perfect squares modulo a given prime. For example, modulo 3, only 0 and 1 are perfect squares (since $0^2 = 0$, $1^2 = 1$, $2^2 = 4 \equiv 1$). That means one-third of all possible steps can be immediately ruled out.

Now here's where it gets remarkable. By combining these filters across multiple small primes — 3, 5, 7, 11, 13, 17, 19, 23, 29, and 31 — using a technique called the Chinese Remainder Theorem, the team proved that **over 99.5% of candidate steps can be skipped**. The survival rate is a precisely computed fraction: 261,273,600 out of 100,280,245,065 — less than one in 384.

This isn't a heuristic or an approximation. It's a mathematically proven bound, verified line by line by a computer theorem prover called Lean 4. The computer checked every step of the reasoning and confirmed: the proof is correct.

## From Square Root to Fourth Root

The basic IOF algorithm finds a factor of $N$ in about $\sqrt{N}$ steps — roughly the same as brute-force trial division. That's not competitive for large numbers. But the team's "Energy-Guided" variant, EG-IOF, does something much cleverer.

Instead of checking one polynomial at each step, EG-IOF checks many polynomials simultaneously, each with a different "stride." Imagine searching for a specific house on a long street. Instead of walking door to door, you send out multiple scouts: one checks every house, another checks every second house, a third checks every third house, and so on. Together, they cover the street much faster than any one of them alone.

The team proved that with $\sqrt{p}$ scouts (where $p$ is the prime factor you're seeking), each scout only needs to check $\sqrt{p}$ houses. Since $p$ itself is at most $\sqrt{N}$, the total work drops to $N^{1/4}$ — the **fourth root** instead of the square root.

For a number the size of an RSA-2048 encryption key (about 617 digits), this is the difference between $2^{1024}$ operations and $2^{512}$ operations. That's still astronomically large — but it's the same ballpark as Pollard's rho algorithm, one of the standard tools in a cryptographer's toolkit.

## A Bridge Between Two Worlds

One of the most intriguing findings connects the IOF framework to the **Number Field Sieve** (NFS), the fastest known classical factoring algorithm. Both methods, it turns out, rely on the same deep algebraic property: the **multiplicativity of norms**.

In IOF, the relevant norm is the Pythagorean one: $N(a + bi) = a^2 + b^2$, which measures the "size" of a Gaussian integer. In the NFS, it's the algebraic norm in a number field: $N(a + b\sqrt{d}) = a^2 - db^2$.

The team proved that these are both instances of the same identity:

$$(a_1^2 - d \cdot b_1^2)(a_2^2 - d \cdot b_2^2) = (a_1 a_2 + d \cdot b_1 b_2)^2 - d(a_1 b_2 + b_1 a_2)^2$$

Setting $d = -1$ recovers the Pythagorean case. Setting $d = $ other values recovers the NFS case. This raises a tantalizing question: **is there a unified framework that combines the geometric intuition of IOF with the algebraic power of the NFS?**

No one knows yet. But the fact that both approaches share the same algebraic backbone suggests they might be two views of the same mountain.

## The Quantum Horizon

Looking further ahead, the team explored what happens when you add quantum computing to the mix. A quantum computer running Grover's algorithm can search an unstructured database of $S$ items in $\sqrt{S}$ steps, compared to the classical $S$ steps.

Applied to the EG-IOF's multi-stride search, this would reduce the factoring complexity from $N^{1/4}$ to approximately $N^{1/6}$ — pushing deeper into territory that starts to concern cryptographers. For context, $2^{2048/6} \approx 2^{341}$, which is still infeasible with current technology but represents a significant theoretical advance.

The required quantum circuits would need to perform "batch GCD" operations — computing the greatest common divisor of a large accumulated product with $N$. The team proved that this batch approach is mathematically sound: if any element in a batch shares a factor with $N$, the product of the batch does too.

## The Continuous Dream

Perhaps the most mathematically beautiful direction involves replacing the discrete step-by-step descent with a continuous flow. Instead of hopping from one Pythagorean triple to the next, imagine sliding smoothly down an energy landscape.

The team proved that the IOF energy function $E(k) = (N - 2k)^2$ has all the properties of a **Lyapunov function** — the mathematical object that guarantees a dynamical system converges to its target:

- It has a unique minimum (at $k = N/2$)
- It's convex (no false valleys to get stuck in)
- It strictly decreases along the descent (no backtracking)

The continuous version would be governed by the differential equation $dx/dt = -4(N - 2x)$, which has an elegant exponential solution. Whether this continuous perspective reveals additional mathematical structure — perhaps a Hamiltonian system or an integrable system — remains an open question.

## The Ferryman's Ledger

There's an almost poetic quality to the research. The Pythagorean theorem is arguably humanity's oldest mathematical discovery — Babylonian tablets from 1800 BCE show knowledge of Pythagorean triples. The Chinese Remainder Theorem dates to the 3rd century CE. Gaussian integers were introduced in the early 1800s.

Now these ancient tools are being combined with the most modern techniques in mathematics: computer-verified proofs, quantum algorithms, and dynamical systems theory. The resulting formal verification — 55 theorems, zero unproven claims, every step checked by a machine — represents a new standard of mathematical rigor applied to cryptographic research.

The team is careful to note that their $N^{1/4}$ algorithm is **not** a threat to current encryption. RSA-2048 remains secure: $2^{512}$ operations is still far beyond any computer's reach. The General Number Field Sieve, with its sub-exponential $L_N[1/3, c]$ complexity, remains the fastest known approach.

But the geometric framework opens doors that haven't been opened before. The Berggren tree — the ternary structure that generates all primitive Pythagorean triples from the root $(3, 4, 5)$ — turns out to have surprisingly deep connections to modular forms, Lorentz geometry, and quantum information theory.

## What's Next

The immediate next step is implementation: building the EG-IOF algorithm and benchmarking it against existing methods on known factoring challenges. The medium-term goal is to understand whether the IOF–NFS bridge can be crossed in both directions — importing NFS techniques into the geometric framework, and vice versa.

The long-term dream? An algorithm that combines the geometric elegance of Pythagorean descent with the algebraic power of number fields, accelerated by quantum mechanics, to achieve a fundamentally new approach to the factoring problem.

It may take decades. It may turn out to be impossible. But the foundations are now formally verified, and the path forward is clearer than ever.

As one team member put it: "We're not trying to break RSA tomorrow. We're trying to understand *why* factoring is hard — and whether the geometry of right triangles has something to say about it."

If the Pythagoreans could see what their simple equation $a^2 + b^2 = c^2$ has become, they might need a moment to sit down.

---

*The mathematical foundations described in this article have been formally verified in the Lean 4 theorem prover. The complete formalization, including 55+ verified theorems with zero unproven claims, is available in the project's `FutureResearchProofs.lean` file. Additional verified theorems appear in `FutureResearch.lean`, `IOFCore.lean`, `IOFSpeedup.lean`, `EnergyDescentResearch.lean`, and `InsideOutResearch.lean`.*
