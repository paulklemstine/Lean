# I Can Prove Fermat's Last Theorem — And I Won't Tell You How

## A story about conviction without disclosure

Imagine a mathematician — call her Nora — who walks into a seminar and announces that she has settled a famous open problem. The audience asks the obvious question: *show us the proof*. Nora refuses. The proof, she says, is hers; she intends to publish it later, or sell it, or keep it forever. But she is willing to do something stranger: she will let the audience run an experiment on her, at the end of which they will be rationally certain that she really does hold a proof — while learning literally nothing about what that proof says.

This sounds like a magic trick, and in a sense it is. But it is a *theorem*, not a trick, and the purpose of this article is to explain exactly which theorem, exactly how much it delivers, and — just as importantly — exactly where it stops delivering. The last part is the interesting part. The mathematics below includes several results that are, frankly, bad news for the folklore that surrounds this subject: one shows that removing the interaction from the protocol destroys its soundness *unconditionally*, and another shows that the whole apparatus can be made completely vacuous by a bad encoding, no matter how good the cryptography is.

## The commitment game

The engine underneath everything is an old and beautiful idea called a *three-move protocol*, or Σ-protocol. Here is the setting, stripped to its bones.

There are two abelian groups $G$ and $H$ and a homomorphism $f : G \to H$ — a map respecting addition, $f(x+y) = f(x) + f(y)$. There is a public element $T \in H$, the *target*. The pair $(f, T)$ is the **statement**, and it should be read as the assertion

$$\exists\, w \in G : f(w) = T.$$

Such a $w$ is a **witness**. The prover claims to know one; the verifier wants to be convinced, and the prover wants to reveal nothing.

The conversation has three moves.

1. **Commit.** The prover draws a uniformly random *tape* $r \in G$ and sends $a = f(r)$.
2. **Challenge.** The verifier flips a fair coin $c \in \{0,1\}$ and sends it.
3. **Respond.** The prover sends $z = r + c\,w$ — that is, $z = r$ if the coin came up $0$, and $z = r + w$ if it came up $1$.

The verifier accepts if and only if
$$f(z) = a + c\,T.$$

Why is this convincing? Because the prover had to commit to $a$ *before* seeing the coin. If she can answer both coins at the same commitment — producing $z_0$ with $f(z_0) = a$ and $z_1$ with $f(z_1) = a + T$ — then subtracting gives
$$f(z_1 - z_0) = T,$$
so $z_1 - z_0$ **is** a witness. This is the extraction principle, and it is the entire source of conviction: anyone who can answer both questions demonstrably possesses the secret. A cheat who has no witness can answer at most one of the two coins, so she is caught with probability at least $1/2$.

Why does it reveal nothing? Because for a fixed coin $c$, the response $z = r + cw$ is a uniformly random element of $G$ (the tape $r$ was uniform, and adding a constant permutes a group), and the commitment $a = f(z) - cT$ is then determined by $z$. So the entire conversation is a deterministic function of one uniform group element. A **simulator** who knows nothing but the public statement can produce exactly the same conversation: pick $z \in G$ uniformly, set $a := f(z) - cT$, and output $(a, c, z)$.

That gives the first of the results this article is about.

> **Perfect Zero-Knowledge Theorem.** Fix a statement $(f,T)$ with a witness $w$ and a challenge $c$. As the tape $r$ ranges over $G$, the honest conversations $(f(r),\,c,\,r+cw)$ form exactly the same multiset as the simulated conversations $(f(z)-cT,\,c,\,z)$ as $z$ ranges over $G$. In particular, the verifier's view is *independent of the witness*: two provers holding different witnesses produce identically distributed conversations.

The proof is one line once you see it: the map $r \mapsto r + cw$ is a bijection of $G$, and it carries the honest conversation at tape $r$ to the simulated conversation at response $r + cw$. Everything else is bookkeeping.

## Repeat until certain

One round leaves a cheater a $50\%$ chance. Run $n$ rounds in parallel — the prover posts $n$ commitments $a_1,\dots,a_n$ at once, the verifier sends a whole vector of coins $c \in \{0,1\}^n$, and the prover answers all $n$ rounds — and the picture becomes stark.

> **Amplified Soundness Dichotomy.** Fix a committed prover: a choice of commitments $a_1,\dots,a_n$ made before any coin is seen, together with an arbitrary (even computationally unbounded, even adversarially clever) response function. Then exactly one of the following holds. Either the statement has *no* witness, in which case the set of challenge vectors the prover can answer contains **at most one** of the $2^n$ vectors; or the statement has a witness, in which case an honest prover answers **all $2^n$** of them.

There is no middle ground: the accepting fraction is either $\le 2^{-n}$ or exactly $1$. For $n = 10$ that is a gap between $1/1024$ and certainty; for $n = 128$ it is a gap no physical adversary can cross.

The proof of the "at most one" half is a small gem. Suppose a committed prover answers two *distinct* challenge vectors $c \ne c'$. They differ in some coordinate $i$, so at commitment $a_i$ the prover has answered both coins — and the extraction principle then manufactures a witness out of thin air, contradicting the assumption that none exists.

## From group elements to theorems

So far this is about solving $f(w) = T$ in a group. What does it have to do with Fermat's Last Theorem?

The bridge is a *compiler*. Fix a formal proof system: a set of statements, a set of candidate proof objects, and a checking relation "$p$ is a valid proof of $T$". A **compilation** of a theorem $T$ into the group world consists of a public statement $(f, \mathrm{target})$ and an encoding $E$ of proof objects as group elements, subject to two faithfulness conditions:

- every checking proof encodes to a witness: if $p$ checks $T$, then $f(E(p)) = \mathrm{target}$;
- every witness testifies to provability: if $f(w) = \mathrm{target}$ for some $w \in G$, then $T$ really does have a checking proof.

The two conditions together say exactly:

> **Provability Equivalence.** The theorem $T$ is provable in the formal system if and only if the compiled public statement has a witness.

And now everything transfers. The verifier is running a protocol about group elements, but by the equivalence she is learning a fact about *mathematics*:

> **Zero-Knowledge Provability Transfer.** Let $T$ be compiled as above. Then:
> 1. Any two checking proofs of $T$ — a two-line one and a two-hundred-page one — induce *identical* verifier views.
> 2. That common view is already produced by the proof-free simulator, which sees only the public statement.
> 3. Nevertheless, a prover who answers both challenges at a single commitment certifies that $T$ genuinely has a proof in the formal system.
>
> Consequently, if $T$ is *not* provable, a committed prover survives $n$ parallel rounds with probability at most $2^{-n}$.

Point (1) is the punchline of the seminar story. If Nora and a rival both hold proofs of the same theorem, their transcripts are drawn from *the same distribution*. Nothing in the conversation distinguishes an elegant proof from an ugly one, a short proof from a long one. Point (3) is why the audience believes her anyway. The protocol transmits precisely one bit — "$T$ is provable" — and provably nothing else.

## Counting the bits

That "nothing else" deserves to be made quantitative, and here the analysis takes a sharp turn. Instead of comparing distributions, one can ask a blunter question: how big is the space of conversations the verifier could possibly see?

> **Geometry of Acceptance.** For any statement $(f,T)$ whatsoever — true, false, with or without a witness — and any fixed challenge $c$, the set of accepting conversations with that challenge is *exactly* the range of the simulator. That is,
> $$\{(a,c,z) : f(z) = a + cT\} = \{(f(z)-cT,\;c,\;z) : z \in G\}.$$

The proof is immediate from the verification equation: it determines $a$ from $z$ and $c$. But the consequence is not.

> **View-Size Theorem.** If $G$ is finite, then for every challenge $c$ the accepting set has exactly $|G|$ elements. The verifier's view is uniform on a set of size $|G|$, carrying exactly $\log_2 |G|$ bits — all of them supplied by the prover's random tape, none by the witness. This count does not depend on the target, on the statement, or on whether a witness exists at all.

Both challenges give the same count, so even the coin itself leaks nothing. Concretely: over the group $\mathbb{Z}/12$ with $f(x) = 4x$, the true statement "$4w = 8$" and the false statement "$4w = 1$" each admit exactly $12$ accepting conversations per challenge. The *shape* of what the verifier can see is completely blind to the truth of what is being claimed. Conviction comes only from the prover's ability to answer *many* challenges, never from the look of any single transcript.

## Killing a piece of folklore

Practitioners often explain zero knowledge like this: "the protocol hides the witness because there are lots of witnesses consistent with the public statement, and the verifier can't tell which one you have." It is a comforting story. It is also wrong.

The witness set here has exact structure: if $w_0$ is one witness, then the witnesses are precisely $w_0 + \ker f$, a coset of the kernel. So the number of witnesses equals $|\ker f|$, and extraction can only ever pin the witness down modulo $\ker f$. In the $\mathbb{Z}/12$ example, $\ker(x \mapsto 4x)$ has four elements, and indeed "$4w=8$" has exactly four solutions: $2, 5, 8, 11$.

But now make $f$ injective. Then $\ker f = 0$, there is exactly **one** witness, and the "ambiguity" explanation has nothing left to stand on.

> **Unique-Witness Zero-Knowledge Theorem.** Suppose $f$ is injective, so the statement determines its witness uniquely. The verifier's view is nevertheless *exactly* the simulator's output — perfect zero knowledge, with no ambiguity anywhere.

Privacy does not come from having many secrets. It comes from the translation symmetry of the tape space: the map $r \mapsto r + cw$ is a bijection whatever $w$ is, and that single fact does all the work.

## Why you cannot just remove the conversation

Real deployments hate interaction. The standard fix is the Fiat–Shamir heuristic: replace the verifier's coin by a hash of the commitment, so that the prover generates the challenge herself and publishes a single self-contained string $(a, z)$, accepted when $f(z) = a + H(a)\,T$.

In the idealized, information-theoretic setting studied here — where the prover is not limited in computing power and the hash is an arbitrary function — this fails, and it fails in the most embarrassing possible direction.

> **Fiat–Shamir Inversion.** Fix a statement and consider all hash functions $H : \mathcal{H} \to \{0,1\}$.
> - If the statement is **true** (a witness exists), then *every* hash function admits an accepted non-interactive pair. There is no choice of hash that makes the transform sound.
> - There exists a **forgery-free** hash — one admitting no accepted pair at all — if and only if the statement is **false**.

Read that again: unconditional non-interactive soundness holds exactly when the thing you wanted to prove is untrue. The reason is a fixed-point count. An accepted pair exists iff some $z$ and some bit $c$ satisfy $H(f(z) - cT) = c$; forgery-freeness therefore forces $H$ to be constantly $1$ on the image of $f$ and constantly $0$ on that image shifted by $-T$. Those two requirements are compatible only when the image and its shift are disjoint — which is precisely the statement that $T$ is not in the image, i.e. that the statement is false. (When it is false, the "colour the image $1$, everything else $0$" hash does the job.)

The moral is not that Fiat–Shamir is useless; in practice it is invaluable, and its security rests on computational assumptions about the hash. The moral is that its soundness is *never* information-theoretic. Interaction is not a convenience one can optimize away for free; the coin the verifier flips is load-bearing.

## Bigger coins, and hiding which theorem

Two extensions round out the picture.

First, nothing about the argument needs coins. Replace the group by a vector space over a finite field $\mathbb{F}_q$ with $q$ prime, let $f$ be linear, and draw the challenge $c$ uniformly from $\mathbb{F}_q$; the prover answers $z = r + c\,w$ and the verifier checks $f(z) = a + c\,T$. Extraction now becomes a *linear solve*: from accepting answers $z, z'$ at two **distinct** challenges $c \ne c'$ on the same commitment, one recovers
$$w = (c - c')^{-1}(z - z'),$$
using that $\mathbb{F}_q$ is a field. Perfect zero knowledge holds verbatim, and $n$ parallel rounds now leave a witnessless prover at most a $q^{-n}$ fraction of the $q^n$ challenge vectors. The Boolean protocol is the $q = 2$ member of this family — over an $\mathbb{F}_2$-vector space, "add $w$ if the coin is $1$" is literally scalar multiplication by the challenge.

Second, one can hide *which* theorem one can prove. Given two statements $S_1, S_2$, run both protocols at once with sub-challenges $c_1, c_2$ constrained by $c_1 \oplus c_2 = c$. A prover who knows a witness for $S_1$ chooses $c_2$ freely, *simulates* the right-hand conversation (which she can do without any witness), and is honest on the left; a prover who knows a witness for $S_2$ does the mirror image.

> **Which-Theorem Hiding.** If both statements are true, the left-knowing prover and the right-knowing prover generate *exactly the same multiset of conversations*. Moreover, any two accepted conversations sharing both commitments but answering different challenges force at least one of the two statements to have a witness.

So the verifier is convinced of the disjunction "$T_1$ or $T_2$ is provable" while learning nothing about which. The proof of the hiding half is again a bijection: there is an explicit reparametrisation of the randomness — flip the fake sub-challenge, translate the two tapes — turning one strategy pointwise into the other.

## The honest caveat

It would be dishonest to end on the magic. The compiler has a load-bearing assumption, and it is worth stating what happens when it fails.

> **Vacuity of a Degenerate Compilation.** Take $f = 0$, the zero homomorphism, with target $0$. Then *every* element of $G$ is a witness. Extraction always succeeds, the verifier always accepts, and the protocol certifies exactly nothing beyond what the compiler already assumed when it declared the encoding faithful.

Cryptography cannot manufacture mathematical content. The protocol faithfully transports the assertion "the compiled public statement has a witness" from prover to verifier, with perfect privacy and exponentially small error. Whether that assertion means "Fermat's Last Theorem is provable" depends entirely on the encoding — on someone having established, in ordinary mathematics, that group witnesses correspond exactly to checking proofs. The zero-knowledge machinery is a perfect courier. It is not, and cannot be, a source of truth.

Everything above assembles into one statement, which is a fair summary of the whole subject:

> **Provability Gap.** For a compiled theorem $T$ and any number of rounds $n$: if $T$ is unprovable, then no commitment ever admits accepting answers to both challenges, and a committed prover survives $n$ rounds with probability at most $2^{-n}$. If $T$ is provable, an honest prover answers all $2^n$ challenge vectors while her entire view — of size exactly $|G|$ per challenge, the same size as for a false statement — is reproducible by a simulator that has never seen a proof.

Nora can keep her proof. The seminar can still be sure it exists.
