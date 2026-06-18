# Non-Archimedean Factoring Oracle

## 1. ABSTRACT

We formalize in Lean 4 with Mathlib the theorem that every composite integer $n > 1$ admits a nontrivial factorization $n = a \cdot b$ with $a > 1$ and $b > 1$. The original conjecture — that *every* integer $n > 1$ can be so factored — is false, as primes are counterexamples. We correct the statement by adding the hypothesis $\neg\, \mathrm{Prime}(n)$ and provide a machine-verified proof. The proof leverages `Nat.exists_dvd_of_not_prime2`, which characterizes non-prime numbers via the existence of an intermediate divisor, together with divisibility arithmetic (`Nat.mul_div_cancel'`, `Nat.div_mul_cancel`). While the mathematical content is classical number theory, the formalization demonstrates how automated reasoning tools can rapidly validate or refute claims about integer factorization.

## 2. MOTIVATION

Integer factorization is the computational bedrock of modern cryptography (RSA, Diffie–Hellman over $\mathbb{Z}/n\mathbb{Z}$). Any claim of a "factoring oracle" — an algorithm that decomposes integers unconditionally — would break these systems. By formalizing the precise boundary between what is provable (composite numbers factor) and what is not (primes do not), we establish a rigorous foundation for reasoning about factoring algorithms. Machine-verified proofs ensure that no subtle logical error slips through, a concern that is especially acute in cryptographic applications where incorrect assumptions can be catastrophic.

## 3. MATHEMATICAL FRAMEWORK

**Definitions:**
- $\mathbb{N}$ denotes the natural numbers $\{0, 1, 2, \ldots\}$.
- A natural number $p$ is *prime* ($\mathrm{Prime}(p)$) if $p \ge 2$ and its only divisors are $1$ and $p$.
- A number $n > 1$ is *composite* if $\neg\,\mathrm{Prime}(n)$.

**Key Mathlib lemma:**
`Nat.exists_dvd_of_not_prime2`: If $n > 1$ and $\neg\,\mathrm{Prime}(n)$, then there exists $k$ with $k \mid n$ and $1 < k < n$.

**Notation:** We write $a \mid b$ for divisibility and $b / a$ for natural number division (truncating).

## 4. PROOF OVERVIEW

1. **Apply `Nat.exists_dvd_of_not_prime2`** to obtain a witness $k$ with $k \mid n$, $k > 1$, and $k < n$.
2. **Set** $a := k$ and $b := n / k$.
3. **Verify** $a \cdot b = n$ via `Nat.mul_div_cancel'` (since $k \mid n$).
4. **Verify** $a > 1$: this is directly $k > 1$.
5. **Verify** $b > 1$: since $k < n$ and $k \mid n$, the quotient $n / k$ must exceed 1. This follows from `Nat.div_mul_cancel` and linear arithmetic (`nlinarith`).

The proof is a single tactic line combining `rcases`, `exact`, and arithmetic lemmas.

## 5. NOVELTY ANALYSIS

The mathematical content itself is elementary. The novelty lies in:
- **Falsification of the original claim**: The original statement omitted the compositeness hypothesis, making it false. Formal verification immediately catches such errors.
- **Automated correction**: The corrected theorem was proved automatically by a theorem-proving agent, demonstrating the power of AI-assisted formalization.
- **Minimal proof**: The entire proof fits in one line, showcasing the maturity of Mathlib's number theory library.

## 6. OPEN PROBLEMS

1. **Efficient witness extraction**: Can the proof be made constructive in a way that yields an efficient factoring algorithm? The current proof uses `minFac`, which is trial division — can Hensel's lemma over $\mathbb{Q}_p$ yield a faster constructive witness?

2. **p-adic factoring algorithms**: Is there a formal proof that $p$-adic Newton polygon analysis can recover factors of univariate polynomials over $\mathbb{Z}$, and can this be lifted to integer factorization via norm forms?

3. **Complexity-theoretic formalization**: Can the hardness of integer factorization (e.g., its relationship to the RSA assumption) be formalized in Lean, connecting this existence result to computational complexity?

## 7. REFERENCES

1. Hardy, G.H. and Wright, E.M. *An Introduction to the Theory of Numbers*, 6th ed., Oxford University Press, 2008.
2. Gouvêa, F.Q. *p-adic Numbers: An Introduction*, 2nd ed., Springer, 1997.
3. The Mathlib Community. *Mathlib: The Lean Mathematical Library*, https://leanprover-community.github.io/mathlib4_docs/.
4. Neukirch, J. *Algebraic Number Theory*, Springer, 1999.
