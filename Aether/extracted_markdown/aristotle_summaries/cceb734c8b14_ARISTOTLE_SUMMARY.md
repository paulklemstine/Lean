# Summary of changes for run a2ede7fb-0606-4f56-8962-29b7bf2ecf8d
## Berggren Semigroup: Cancellation, Divisibility, and Cryptographic Reductions

### Formally Verified Mathematics (Lean 4)

I built a complete, sorry-free formal development in three files (642 lines total):

**`Cryptography/Berggren/Defs.lean`** — Foundation layer:
- Defined the three Berggren generators (BGen: A, B, C) and their action on Pythagorean triples
- Proved the **freeness theorem** (`evalWord_injective`): distinct generator words produce distinct triples, using a discriminant classifier that uniquely identifies which generator was applied
- Defined the matrix homomorphism `φ : FreeSemigroup BGen →ₙ* Matrix (Fin 3) (Fin 3) ℤ` and proved it is **injective** (`φ_injective`) — the faithful embedding
- Proved left and right cancellation in the free semigroup, plus the key length monotonicity lemma (`fs_no_right_id`, `fs_no_left_id`)

**`Cryptography/Berggren/Divisibility.lean`** — Core divisibility theory:
- Defined `BerggrenSg` as the image subtype with semigroup multiplication
- Constructed unique normal forms (`nf`, `nf_spec`, `nf_unique`, `nf_mul`)
- Proved **left and right cancellation** on BerggrenSg (`berggren_left_cancel`, `berggren_right_cancel`)
- Defined `LeftDivides` and `RightDivides` (reflexive divisibility relations)
- Proved **left-divisibility is a partial order** with the nontrivial antisymmetry argument: mutual divisibility A|B and B|A forces A = A*(C*D), contradicting `fs_no_right_id`
- Proved **`leftDivides_iff_prefix`**: left-divisibility ↔ prefix order on normal forms (the key bridge theorem)
- Similarly for right-divisibility ↔ suffix order
- Proved unique quotient theorems

**`Cryptography/Berggren/LCP.lean`** — LCP, decidability, and oracle reductions:
- Defined `lcpList` (longest common prefix on lists) with its universal property
- Proved `lcpList_greatest`: the LCP is the greatest common prefix
- Proved `isPrefixFS_iff`: translated between semigroup prefix and list prefix
- Proved **decidability of left-divisibility** via the prefix equivalence
- Proved **greatest lower bound** existence when the LCP is nonempty
- Proved the **secret suffix uniqueness theorem**: ∃! U, nf(A*T) = nf(A) * U
- Proved the **oracle reduction theorem**: any oracle recovering nf(A) from homomorphic images uniquely determines the secret suffix nf(T)

All proofs use only standard axioms (propext, Classical.choice, Quot.sound).

### Python Demos (`demos/berggren_demo.py`)

Five working demos with numerical verification:
1. **Freeness**: verifies all 39 words of length 1-3 produce distinct Pythagorean triples
2. **Divisibility = Prefix**: demonstrates the matrix factorization M(v) = M(u)·M(w) when u is a prefix of v
3. **Longest Common Prefix**: shows LCP computation as greatest lower bound
4. **Oracle Reduction**: demonstrates that the unique suffix is computationally recoverable
5. **Visualization**: generates `demos/berggren_tree_and_order.png` showing the Berggren tree and its divisibility lattice

### Research Paper (`paper/berggren_divisibility.md`)

A complete mathematical paper covering:
- Formal framework and proof strategy
- All main theorems with proof sketches
- Cryptographic applications and implications
- A "Scientific American"-style discussion section explaining the results to a general audience
- Formal verification summary table mapping theorems to Lean names
- References to Berggren (1934), Barning (1963), and related work

### Significance

This development upgrades the Berggren semigroup from a mere "injective encoding" into a structured algebraic object with:
- A decidable partial order (divisibility)
- A computable GCD-like operation (longest common prefix)  
- A clean oracle reduction showing that prefix recovery ≡ secret extraction

These are the precise algebraic primitives needed for rigorous security analysis of semigroup-based cryptographic protocols.