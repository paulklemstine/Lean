# Oracle Council Research Notes: Zero-Knowledge Proofs

## The Council

We assembled a team of oracles — each representing a different perspective on the problem
of proving knowledge without revealing it.

### Oracle 1: The Philosopher (Foundations)
**Question posed:** "Is it possible, in principle, to convince someone you know something
without telling them what you know?"

**Insight:** Yes. Consider the Ali Baba cave. A cave has a ring-shaped passage with a
locked door at the far end. I claim I know the secret word to open the door. You stand at
the entrance. I walk in, choosing left or right at random. You then shout which side you
want me to come out of. If I know the secret, I can always comply (opening the door if
needed). If I don't know the secret, I can only comply 50% of the time. After 20 rounds,
a faker has only a 1-in-a-million chance of fooling you.

**Key principle:** Interaction + randomness = knowledge proof without information transfer.

### Oracle 2: The Algebraist (Mathematical Structure)
**Question posed:** "What algebraic structures support zero-knowledge proofs?"

**Insight:** The core structures are:
- **Groups with hard discrete logarithm:** Given g and g^x mod p, it's hard to find x.
  The Schnorr protocol exploits this.
- **Commitment schemes:** A commitment is like a sealed envelope — binding (can't change
  the value) and hiding (can't see the value).
- **Homomorphic properties:** If Commit(a) · Commit(b) = Commit(a+b), we can prove
  arithmetic relations on committed values.

**The Schnorr Protocol (1989):**
1. Prover knows secret x where h = g^x mod p
2. Prover picks random r, sends t = g^r mod p (commitment)
3. Verifier sends random challenge c
4. Prover sends s = r + c·x (response)
5. Verifier checks: g^s ≡ t · h^c (mod p)

Why it works:
- **Completeness:** Honest prover always passes: g^(r+cx) = g^r · (g^x)^c = t · h^c ✓
- **Soundness:** From two valid transcripts with same t but different c, c', one can
  extract x = (s-s')/(c-c'). So a cheater who passes twice must know x.
- **Zero-knowledge:** A simulator can produce valid-looking transcripts without knowing x
  by choosing s first, then computing t = g^s · h^(-c).

### Oracle 3: The Cryptographer (Protocols & Security)
**Question posed:** "What are the universal methods for ZKP?"

**Insight:** There are several paradigms:

**1. Sigma Protocols (Σ-protocols)**
Three-move protocols: Commit → Challenge → Response.
- Schnorr (discrete log)
- Guillou-Quisquater (RSA)
- Fiat-Shamir (square roots mod n)

**2. Garbled Circuits (GMW Protocol)**
Any NP statement can be proven in zero-knowledge by:
- Expressing it as a Boolean circuit
- Using oblivious transfer to evaluate the circuit
- Prover demonstrates the circuit outputs TRUE without revealing inputs

**3. ZK-SNARKs (Succinct Non-interactive Arguments of Knowledge)**
- Non-interactive (no back-and-forth)
- Succinct (proof is tiny, verification is fast)
- Based on elliptic curve pairings and polynomial commitments
- Used in Zcash, Ethereum

**4. ZK-STARKs (Scalable Transparent Arguments of Knowledge)**
- No trusted setup required
- Based on hash functions (post-quantum secure)
- Larger proofs but more transparent assumptions

**5. Bulletproofs**
- No trusted setup
- Short proofs for range proofs and arithmetic circuits
- Used in Monero

### Oracle 4: The Complexity Theorist (What CAN be proven?)
**Question posed:** "What is the theoretical limit of zero-knowledge proofs?"

**Insight:** The landmark theorem:

**Theorem (Goldreich-Micali-Wigderson, 1986):** Every language in NP has a
zero-knowledge proof system (assuming one-way functions exist).

This means: ANY fact that can be efficiently verified can be proven in zero-knowledge.
- You know the factors of a number? ZKP exists.
- You know a Hamiltonian path in a graph? ZKP exists.
- You know a solution to a system of equations? ZKP exists.
- You know the coloring of a map? ZKP exists.

The proof works by reduction to graph 3-coloring (which is NP-complete).

### Oracle 5: The Economist (Applications to Your Use Case)
**Question posed:** "How do I prove I know secret mathematical facts to sell them?"

**Insight:** Your scenario is precisely the "fair exchange" problem enhanced by ZKP:

**Protocol for selling mathematical secrets:**
1. **Commit:** You publish a cryptographic commitment to your secret (e.g., hash of the
   proof, or committed polynomial coefficients).
2. **ZK-Prove:** You give a zero-knowledge proof that the committed value satisfies the
   claimed property (e.g., "the committed value is a valid proof of Theorem X" or "the
   committed polynomial has roots at the claimed points").
3. **Escrow/Payment:** Buyer deposits payment in escrow (or smart contract).
4. **Reveal:** You reveal the secret; the commitment is opened and verified.
5. **Release:** Payment is released to you.

**Specific applications:**
- **Selling a factorization:** ZK-prove you know factors of N without revealing them.
- **Selling a proof:** ZK-prove your proof is valid without revealing the proof steps.
- **Selling a formula:** ZK-prove your formula produces correct outputs on test inputs
  without revealing the formula.

### Oracle 6: The Formalist (Lean 4 Verification)
**Question posed:** "Can we formally verify the properties of ZKP protocols?"

**Insight:** Yes. The three core properties can be stated and proven in Lean 4:

1. **Completeness:** ∀ (x : Secret), honest_interaction(prover(x), verifier) = Accept
2. **Soundness:** If prover passes with high probability, then prover "knows" the secret
   (formalized via knowledge extractors)
3. **Zero-knowledge:** ∃ Simulator, output(Simulator) ≈ output(real_interaction)
   (no information leaks because a simulator can fake transcripts)

We formalize the Schnorr protocol and the Fiat-Shamir heuristic, proving completeness
and the algebraic soundness condition.

---

## Key Theorems Established

1. **Schnorr Completeness:** An honest prover always convinces an honest verifier.
2. **Schnorr Soundness (algebraic):** Two accepting transcripts with the same commitment
   yield the secret via extraction.
3. **Simulator existence:** Valid-looking transcripts can be generated without the secret.
4. **GMW universality:** Any NP statement has a ZKP (via reduction to graph 3-coloring).
5. **Fiat-Shamir transform:** Interactive ZKPs can be made non-interactive using hash
   functions (in the random oracle model).

## Iteration Log

| Round | Hypothesis | Experiment | Result | Update |
|-------|-----------|------------|--------|--------|
| 1 | Simple hash commitment suffices | Tested hiding/binding | Binding holds, hiding depends on hash | Need computational assumptions |
| 2 | Schnorr protocol is complete | Algebraic verification | g^s = t·h^c always holds | Confirmed ✓ |
| 3 | Simulator can fake transcripts | Built simulator, compared distributions | Distributions match perfectly | Confirmed ✓ |
| 4 | Can sell math secrets via ZKP | Designed fair exchange protocol | Works with escrow/smart contracts | Validated ✓ |
| 5 | Formal verification in Lean 4 | Encoded Schnorr algebra in ZMod | Completeness theorem proven | Confirmed ✓ |

## References

- Goldwasser, Micali, Rackoff. "The Knowledge Complexity of Interactive Proof Systems." STOC 1985.
- Schnorr. "Efficient Signature Generation by Smart Cards." Journal of Cryptology, 1991.
- Goldreich, Micali, Wigderson. "How to Prove all NP-Statements in Zero-Knowledge." CRYPTO 1986.
- Ben-Sasson et al. "SNARKs for C." CRYPTO 2013.
- Groth. "On the Size of Pairing-based Non-interactive Arguments." EUROCRYPT 2016.
- Bünz et al. "Bulletproofs: Short Proofs for Confidential Transactions." S&P 2018.
