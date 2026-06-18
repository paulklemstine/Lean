# Summary of changes
# Four-Channel Integer Signatures: Research Exploration

## What was built

I created a research team's worth of formalized mathematics, computational experiments, and detailed research notes exploring the hypotheses about four-channel integer signatures (r₂, r₄, r₈ — representations as sums of 2, 4, and 8 squares).

## Project Structure

### Formal Definitions (`RequestProject/Defs.lean`)
- Defined χ₋₄ (non-principal Dirichlet character mod 4), r₂, r₄, r₈ using their closed-form divisor-sum formulas
- Four-channel signature type, distance metric, and normalized signatures

### Computational Experiments (`RequestProject/Experiments.lean`, `Experiments2.lean`)
**19 experiments** testing the hypotheses. Key findings:

| Hypothesis | Status | Evidence |
|-----------|--------|---------|
| H1 (Signature Distance) | **Partially Refuted** | Raw distance dominated by r₈~n³; needs normalization |
| H2 (Channel Entropy) | **Confirmed** | Channel 4 carries >99% of info even at n=100 |
| H3 (Quantum Interference) | **Open** | Interference terms I(m,n) = r₄(m+n)-r₄(m)-r₄(n) vary wildly |
| H4 (Prime Distribution) | **Confirmed** | Two classes, constant gap of 8 |
| Prediction 2 (Channel ratio) | **Corrected** | r₈/r₄ = 2(p²-p+1), not p²-p+1 |
| Prediction 3 (Product formula) | **Confirmed** | Even powers transparent, odd powers block |

**Surprise discoveries:**
- Powers of 2 have CONSTANT r₂=4 and r₄=24 for all k — information lives entirely in Channel 4
- 57% of integers ≤100 are "dark matter" (r₂=0), rising to 65% at N=500
- Both r₄/8 and r₈/16 are multiplicative for coprime arguments (refuting Hypothesis C)
- All even perfect numbers are dark matter in Channel 2

### Formal Proofs — 26 Theorems, Zero Sorry

**`ChannelEntropy.lean`** (13 theorems):
- r₄(p) = 8(p+1) and r₈(p) = 16(1+p³) for odd primes
- Channel dominance: r₈(p) > r₄(p) for p ≥ 2
- r₂(p) = 8 for p≡1(mod 4), r₂(p) = 0 for p≡3(mod 4)
- Sum-of-cubes factorization: 1+p³ = (p+1)(p²-p+1)

**`PrimeSignatures.lean`** (4 theorems):
- r₄ is residue-class-blind for primes
- Constant signature gap theorem: the Channel 2 difference between class A and B primes is always exactly 8
- Corrected Eisenstein norm connection: ratio = 2(p²-p+1)

**`SumOfSquaresFilter.lean`** (5 theorems):
- Fermat's two-squares theorem (p≡1 mod 4 → sum of two squares)
- Primes p≡3(mod 4) are NOT sums of two squares
- Brahmagupta-Fibonacci identity (closure under multiplication)
- Perfect squares are trivially sums of two squares

**`Multiplicativity.lean`** (4 theorems):
- σ₁*(1) = 1 and σ₃±(1) = 1 (base cases for multiplicativity)
- σ₁*(p) = p+1 and σ₃±(p) = 1+p³ for odd primes

### Research Notes (`RequestProject/Notes.md`)
Comprehensive 300-line document covering:
- All experimental results with data tables
- Updated hypothesis status (confirmed/refuted/open)
- 5 key discoveries with mathematical explanations
- 3 refined hypotheses for future investigation
- 7 prioritized next steps