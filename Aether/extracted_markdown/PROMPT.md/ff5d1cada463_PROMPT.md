Clean up the previous malformed artifact by producing one actual compilable Lean file in cryptography, with zero `sorry`s and no narrative text embedded in code. Focus only on the one-time pad over a finite group; do not mix in RSA, tropical geometry, or unrelated algebra.

Create a file such as `Catalog/Cryptography/OneTimePadSecrecy.lean` that works over a type `G` with `[Group G] [Fintype G] [DecidableEq G]`. Define encryption by group multiplication, e.g. `enc (k m : G) : G := k * m`.

Primary formal targets, in this order:
1. Prove a unique-key theorem: for any `m c : G`, there exists a unique `k : G` such that `enc k m = c`. The witness should be `c * m⁻¹`.
2. Derive a counting theorem saying the finite set `{k : G | enc k m = c}` has cardinality `1`.
3. Prove the combinatorial perfect secrecy statement: for any `m₁ m₂ c : G`, the number of keys sending `m₁` to `c` equals the number sending `m₂` to `c`.
4. Only if the probability/distribution API is robust and compiles cleanly, formalize the probabilistic corollary that the pushforward of the uniform distribution on `G` under `k ↦ enc k m` is uniform, and therefore identical for all plaintexts `m`. If this introduces instability, omit it and keep the file centered on the exact finite-counting theorem.

Preferred proof strategy: use the fact that right-multiplication by a fixed group element is a bijection, or explicitly solve `k * m = c` by group cancellation. Keep the development elementary and self-contained. Use `Fintype.card`, `Finset.filter`, or equivalent finite-set cardinality lemmas as appropriate. Avoid introducing heavy probability machinery unless it is already straightforwardly supported.

Deliverables:
- One new Lean file with complete proofs and no `sorry`s.
- The theorem statements should be explicit and reusable, with names like `otp_unique_key`, `otp_key_count`, and `otp_perfect_secrecy`.
- Ensure the file is syntactically clean and compiles on its own.

Important: this is a `sorry_fill` recovery task. The goal is not to broaden the research program but to replace the previous non-compiling narrative with a correct formal artifact for the OTP secrecy theorem.