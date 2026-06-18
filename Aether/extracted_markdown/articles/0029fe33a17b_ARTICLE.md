# The Sound of Squares: When Mathematical Proof Systems Hit a Mirror

## A hidden symmetry in the mathematics of trust reveals why some secrets can never be fully extracted — and opens a new chapter in the algebra of verification

---

Imagine you are trying to verify that someone knows a secret number. Not just any number — a specific one, tied to a cryptographic lock. The classic approach in modern cryptography is elegant: you challenge the prover with a random question, they respond, and from their response you can mathematically reconstruct the secret. Two challenges, two responses, one secret recovered. It works like triangulation: two sightlines from different angles pinpoint a single location.

This principle, called *special soundness*, has been the bedrock of interactive proof systems for over three decades. It underlies everything from digital signatures to anonymous credentials to blockchain consensus. And for the systems that have been deployed — where the mathematics is linear — it works perfectly.

But what happens when the mathematics is not linear?

A new body of work reveals a surprising and fundamental answer: when the relationship between the secret and the response becomes nonlinear — say, quadratic instead of linear — two challenges are no longer enough. Not because the algebra gets harder. Because the algebra changes its character entirely. The problem stops being triangulation and starts being something closer to acoustics.

---

## The Linear World: Perfect Triangulation

In the simplest interactive proof systems, the prover knows a secret number *w* and responds to a challenge *c* with a value *z* that satisfies an equation like:

> z = t + c · w

where *t* is a random blinding factor chosen by the prover. The verifier sees *z* and *c* but not *t* or *w* individually.

Here is the key insight that makes extraction work: if the verifier can obtain two responses with *different* challenges but the same blinding, they can subtract one equation from the other:

> z₁ − z₂ = (c₁ − c₂) · w

Since c₁ ≠ c₂, you can divide and recover *w* exactly. Two data points, one unknown, perfect recovery. This is linear algebra at its most basic — and most powerful.

Every deployed Σ-protocol (as these proof systems are technically called) relies on this linearity. Schnorr signatures, Chaum–Pedersen proofs of equality, Okamoto's two-generator protocol — all are variations on the same linear theme. The mathematics is clean, the extraction is deterministic, and the security proofs are airtight.

## The Nonlinear Frontier

Now consider a natural generalization. Instead of the secret appearing linearly in the response, suppose it appears through some function *f*:

> z = t + c · f(w)

If *f* is the identity — f(w) = w — we are back in the linear world. But what if f(w) = w²? Or w³? Or any nonlinear function?

This is not an academic curiosity. Quadratic relations arise naturally in cryptographic constructions involving pairings, lattice-based schemes, and algebraic hash functions. As cryptography moves toward post-quantum security and more complex algebraic structures, nonlinear response functions are becoming increasingly relevant.

The question is: does the extraction trick still work?

## The Mirror in the Mathematics

The answer, it turns out, is both yes and no — and the boundary between them is razor-sharp.

When you subtract two transcript equations with a nonlinear *f*, you get:

> z₁ − z₂ = (c₁ − c₂) · f(w)

You can still divide by (c₁ − c₂) and recover... *f(w)*. Not *w* itself, but its image under *f*.

This is a profound distinction. In the linear case, f(w) = w, so recovering the image *is* recovering the secret. But when *f* is nonlinear, knowing f(w) is not the same as knowing *w*.

Consider the simplest nonlinear case: f(w) = w². If you learn that w² = 9 in ordinary arithmetic, do you know *w*? No — it could be 3 or −3. In a finite field of prime order *p*, the situation is exactly analogous: every nonzero square has exactly two square roots, *w* and *−w*. These two values are mirror images of each other under negation, and they produce *identical* transcript data.

This is not a bug in the extraction procedure. It is a theorem about the structure of the problem. Two transcripts can recover the *square* of the witness, but never the witness itself when squaring is the response function. The mirror symmetry w ↦ −w is invisible to the transcript data.

## A Formal Boundary Theorem

What has now been proven — with complete mathematical rigor — is a precise characterization of this phenomenon:

**Theorem (Image Determination).** For any function *f* and any two distinct challenges, if two witnesses produce identical transcript pairs, then f(w₁) = f(w₂). That is, transcript data determines the polynomial image.

**Theorem (Extraction Dichotomy).** Two-transcript witness extraction succeeds if and only if *f* is injective. If *f* has any collisions — any two distinct inputs mapping to the same output — then there exist distinct witnesses that are indistinguishable from transcript data.

**Theorem (Quadratic Obstruction).** Over any field where 2 ≠ 0, the squaring map f(w) = w² is not injective, and therefore quadratic protocols are never two-transcript extractable.

These theorems are not merely plausible arguments or informal sketches. They have been machine-verified, checked line by line by a computer, with every logical step validated. The proofs are constructive: they exhibit explicit witnesses, explicit transcripts, and explicit collisions.

## The Observation Map: A New Abstraction

The deeper insight is not just about what fails, but about what succeeds. The correct mathematical object is not the witness *w* but the *observation map*: the function that sends a witness-blinding pair (t, w) to the full vector of transcript responses across all challenges.

This map factors through the pair (t, f(w)). Always. Regardless of how many challenges you use. The transcript data can see only the shadow cast by *f*, never the witness behind it.

This factorization is the key to understanding extraction in nonlinear systems. It tells you exactly what information is accessible and what is hidden. It replaces the old question "can we extract the witness?" with the sharper question "what is the fiber of the observation map?" — and the answer is controlled by the fibers of *f*.

## From Algebra to Geometry

There is a beautiful geometric picture lurking behind these algebraic statements. Each transcript equation

> z = t + c · f(w)

defines a surface in the space of unknowns (t, w). A family of transcripts defines a family of such surfaces. Extraction means finding the intersection — the set of (t, w) pairs consistent with all the data.

In the linear case, these surfaces are hyperplanes, and two of them (with distinct challenges) intersect in a single point. This is just the geometry of solving two equations in two unknowns.

In the nonlinear case, the surfaces are curved. For f(w) = w², they are parabolas (or their finite-field analogues). Two parabolas can intersect in more than one point — and the extra intersection points are precisely the "ghost witnesses" that the extractor cannot distinguish from the true one.

This perspective reframes cryptographic extraction as a problem in algebraic geometry: computing the dimension and structure of the intersection variety defined by transcript equations. It is the beginning of what might be called *transcript geometry*.

## The Algorithm That Works

Despite the impossibility of full witness extraction, there is a verified algorithm that does something precise and useful: it extracts the polynomial image.

Given two transcripts (c₁, z₁) and (c₂, z₂) with c₁ ≠ c₂, the algorithm computes:

> y = (z₁ − z₂) / (c₁ − c₂)
> t = z₁ − c₁ · y

and returns (t, y) where y = f(w). This algorithm has been proven correct: under the stated assumptions, it always returns the true blinding and the true image value.

This is not a partial failure — it is a partial success. The algorithm recovers everything that *can* be recovered from the data. The remaining ambiguity — the fiber of *f* over the extracted image — is irreducible. It is not a deficiency of the algorithm but a property of the mathematics.

## Why This Matters

The practical implications ripple outward in several directions.

**For protocol designers:** If your proof system has a nonlinear response function, you cannot claim standard 2-special soundness. You must either prove that *f* is injective on the relevant domain, or explicitly state that your protocol achieves only *image-level* extraction — proof of knowledge of f(w), not of w itself.

**For security analysts:** The fiber structure of *f* directly controls the security loss. For f(w) = w^d over a field of order p, the number of compatible witnesses for each extracted image is exactly gcd(d, p − 1). This is a computable, predictable quantity that belongs in security proofs.

**For the theory of proof systems:** The observation map framework provides a unified language for analyzing extraction in any algebraic proof system, not just affine ones. The right question is not "is this linear?" but "what is the observation map, and what are its fibers?" This opens a research program connecting cryptography to elimination theory, algebraic statistics, and computational algebra.

## The Bigger Picture

For decades, special soundness was understood as a trick of linear algebra. You subtract two equations, cancel the blinding, and solve for the witness. It seemed too simple to have hidden depths.

What the nonlinear theory reveals is that this simplicity was an artifact of linearity, not a feature of the extraction problem itself. The real structure is richer: extraction is governed by the algebraic geometry of the response function. Linearity is the special case where the geometry is trivial — all varieties are flat, all intersections are transversal, all fibers are singletons.

Move one step beyond linearity, and you enter a world where symmetry obstructs extraction, where fibers have nontrivial structure, and where the number of transcripts needed for recovery depends on the algebraic degree of the response function. It is a world where special soundness is not a local technique but a chapter of elimination theory.

The sound of a linear protocol is a pure tone — one note, one frequency, uniquely identifiable. The sound of a quadratic protocol is a chord — multiple notes producing the same harmonic energy, fundamentally ambiguous to the listener. To identify the individual notes, you need not just more measurements, but measurements of a fundamentally different kind.

That distinction — between hearing a note and hearing its energy — is the mathematical boundary this work has charted. It is simple enough to state in a sentence, deep enough to open a research program, and precise enough to be checked by a machine. The algebra of trust has a new chapter, and it begins with a square.
