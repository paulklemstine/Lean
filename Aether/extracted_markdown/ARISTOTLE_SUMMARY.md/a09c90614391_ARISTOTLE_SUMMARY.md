# Summary of changes for run 73d1cb4d-909b-4138-8321-3dda2b1d33b9
## Completed: Code-Based Cryptography Formalization

### Files Created
1. **`Catalog/Cryptography/McElieceCodes.lean`** (275 lines) — Complete Lean 4 formalization with zero `sorry` statements
2. **`FUTURE_DIRECTIONS.md`** — 5 research directions for extending the work

### Main Theorems (all fully proved, no sorry)

1. **McEliece Decryption Correctness** (`mcEliece_decrypt_correct`): If the underlying code has a t-error-correcting bounded-distance decoder, then for any codeword c and error vector e with wt(e) ≤ t, the decoder applied to c + e recovers c exactly.

2. **Singleton Bound** (`singleton_bound`): For any [n,k,d] linear code, d ≤ n - k + 1. Codes meeting this bound with equality are MDS (Maximum Distance Separable).

3. **Unique Decoding Guarantee** (`unique_decoding`): If two codewords have Hamming distance ≥ d, and a received word r is within distance t = ⌊(d-1)/2⌋ of one codeword, then r is at distance > t from the other. This is the foundation of bounded-distance decoding. Proved using the Hamming distance triangle inequality and the error-correction radius bound.

4. **Permutation Invariance of Hamming Weight** (`hammingWt_comp_perm`): Composing a vector with a permutation does not change its Hamming weight. This is the key property making the McEliece cryptosystem work — the permutation matrix P in the public key G' = S·G·P does not affect error-correcting capability. Proved via a Finset bijection argument.

### Additional Results (all proved)
- **Hamming distance metric properties**: triangle inequality, symmetry, identity of indiscernibles
- **Hamming distance permutation invariance** (`hammingDist_comp_perm`)
- **MDS code duality**: if [n,k,d] is MDS then [n, n-k, k+1] is also MDS
- **MDS fundamental equation**: k + d = n + 1
- **Post-quantum parameter verification**: Classic McEliece mceliece6960119 (k=5413, d≥239) and mceliece8192128 (k=6528, d≥257) parameter arithmetic verified by `decide`
- **Hamming ball volume** monotonicity and positivity
- **Code permutation equivalence** reflexivity

All proofs use only standard axioms (propext, Classical.choice, Quot.sound).