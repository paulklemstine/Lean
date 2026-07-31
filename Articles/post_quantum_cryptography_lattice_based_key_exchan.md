# The Quarter-Modulus Safety Zone: How Noisy Lattice Keys Survive Errors and Compromise

Modern cryptography has an unusual design problem. A useful secret must be hidden so thoroughly that an observer cannot recover it, yet two honest participants must still perform enough arithmetic with that secret to arrive at exactly the same key. Lattice-based cryptography approaches this tension by deliberately adding noise. The noise conceals linear structure from an attacker, but it also threatens to make honest computations disagree.

The mathematics here isolates two mechanisms that make an LWE-style key exchange intelligible. The first is a **reconciliation margin**: a clean inequality guaranteeing that accumulated errors remain inside a safe decoding region. The second is a **post-compromise hybrid principle**: if either of two challenge-session views is close to one common ideal distribution, then revealing a static key still leaves those sessions hard to distinguish. Together they describe reliability and a precise, conditional form of forward secrecy. A concrete parameter profile then shows how the arithmetic behaves for dimension $512$, prime modulus $12289$, $1024$ bounded error terms, and error magnitude at most $3$.

## Hiding a signal with deliberate imperfection

Learning With Errors, or LWE, begins with approximate linear equations modulo an integer $q$. A typical sample has the shape

$$
b = \langle a,s\rangle + e \pmod q,
$$

where $a$ is public, $s$ is secret, and $e$ is a small error. Without $e$, sufficiently many equations invite ordinary linear algebra. With small, independently generated errors, extracting $s$ is believed to be difficult for appropriately chosen parameters, including against quantum attackers.

This same noise can support encryption and key establishment. Public values contain noisy linear information; participants combine them using secret values; and algebra causes the intended shared term to agree while leaving a residual error. The remaining question is brutally practical: when do both parties round to the same answer?

Picture residues modulo $q$ on a clock. Reconciliation divides this clock into decoding regions. If the two parties’ values differ by less than one quarter of a revolution in the relevant representation, they decode consistently. Thus the critical threshold is $q/4$. One need not know the exact errors—only a reliable upper bound on their total magnitude.

## Many small errors become one controlled error

Suppose a computation accumulates $m$ integer errors $e_1,\ldots,e_m$, each satisfying $|e_i|\le B$. The Accumulated Error Theorem states

$$
\left|\sum_{i=1}^{m} e_i\right|\le mB.
$$

The argument is the triangle inequality. First,

$$
\left|\sum_{i=1}^{m} e_i\right|
\le \sum_{i=1}^{m}|e_i|,
$$

and then each summand is at most $B$, so the right-hand side is at most $mB$.

This elementary estimate is powerful because it is deterministic. It does not ask whether large deviations are unlikely; it says that every vector satisfying the coordinatewise bound is safe whenever the design margin is large enough.

The Reconciliation Margin Theorem makes that statement precise. If $|e_i|\le B$ for all $i$ and

$$
4mB<q,
$$

then

$$
4\left|\sum_{i=1}^{m}e_i\right|<q.
$$

Equivalently, the accumulated error lies strictly inside the quarter-modulus radius:

$$
\left|\sum_{i=1}^{m}e_i\right|<\frac q4.
$$

The word “strictly” matters. A decoder can behave ambiguously on a boundary. The strict inequality leaves no boundary case to resolve.

## A concrete arithmetic profile

Consider the following design-scale values:

- dimension $n=512$;
- modulus $q=12289$;
- number of accumulated errors $m=1024$;
- per-error bound $B=3$.

The modulus $12289$ is prime. Prime moduli are convenient because every nonzero residue has a multiplicative inverse, enabling the field arithmetic used in standard LWE rerandomization arguments.

The worst-case accumulated magnitude is

$$
mB=1024\cdot 3=3072.
$$

Multiplying by four gives

$$
4mB=4\cdot 1024\cdot 3=12288<12289=q.
$$

This is an exceptionally tight safety margin: only one integer separates the worst-case scaled error from the modulus. Nevertheless, it is strict. Therefore every collection of $1024$ integer errors, each of magnitude at most $3$, has total error strictly within the quarter-modulus decoding radius.

The raw secret-vector space also passes a simple size check. There are $q^n=12289^{512}$ vectors over the residue field. Since $12289\ge2$ and $512\ge128$,

$$
2^{128}\le12289^{128}\le12289^{512}.
$$

Hence the raw space contains at least $2^{128}$ candidates. This is a combinatorial fact, not a complete security estimate. A cryptanalytic work factor depends on much more than counting secrets: lattice reduction, dual attacks, decoding attacks, the error distribution, sample counts, and implementation costs all matter. Keyspace size should therefore be read as a sanity check, not as proof of “128-bit security.”

## Measuring what an observer can distinguish

Reliability is only half the story. To discuss secrecy, we need a language for comparing an observer’s possible views.

For a finite set of views $\Omega$, a probability distribution assigns a nonnegative mass $P(x)$ to each $x\in\Omega$, with

$$
\sum_{x\in\Omega}P(x)=1.
$$

For two distributions $P$ and $Q$, define their $\ell^1$ gap by

$$
\Delta_1(P,Q)=\sum_{x\in\Omega}|P(x)-Q(x)|.
$$

A smaller gap means that the distributions are more alike. The usual total variation distance is $\Delta_1(P,Q)/2$, but the unnormalized $\ell^1$ form makes the accounting especially transparent.

The Triangle Inequality for Finite Views states that for any three distributions $P,Q,R$ on the same finite space,

$$
\Delta_1(P,R)\le \Delta_1(P,Q)+\Delta_1(Q,R).
$$

Its proof works view by view. For every $x$,

$$
|P(x)-R(x)|\le|P(x)-Q(x)|+|Q(x)-R(x)|,
$$

and summing over $x$ yields the theorem.

This modest inequality is the engine behind hybrid arguments. Instead of comparing two complicated real experiments directly, compare each with a simpler ideal experiment and add the two losses.

## The common ideal and post-compromise secrecy

Imagine a protocol with a static secret key $k$. After a session ends, an adversary is allowed to learn $k$ and inspect a complete transcript. Let $V_{k,0}$ and $V_{k,1}$ denote the distributions of the resulting views under two challenge-session alternatives. The alternatives might represent two candidate session keys or two hidden challenge bits.

Quantitative forward secrecy at level $\varepsilon$ means that for every exposed static key $k$,

$$
\Delta_1(V_{k,0},V_{k,1})\le\varepsilon.
$$

Now suppose there is a common ideal distribution $I_k$ that may depend on the exposed key but does not depend on the challenge bit. Assume

$$
\Delta_1(V_{k,0},I_k)\le\varepsilon_0
\quad\text{and}\quad
\Delta_1(V_{k,1},I_k)\le\varepsilon_1
$$

for every $k$. The Common-Ideal Forward-Secrecy Theorem concludes that

$$
\Delta_1(V_{k,0},V_{k,1})\le\varepsilon_0+\varepsilon_1.
$$

The proof is a one-line journey through the ideal world: travel from the first real view to $I_k$, then from $I_k$ to the second real view, and invoke the triangle inequality. The symmetry of absolute value lets the second bound be used in the needed direction.

A useful corollary covers equal losses. If both challenge views are within $\varepsilon$ of the common ideal, then the post-compromise distinguishing gap is at most $2\varepsilon$.

In an LWE-based analysis, the two closeness assumptions are where decisional-LWE hardness enters: each real post-exposure view must be replaced by the same challenge-independent ideal view through a justified hybrid step. The theorem does not itself prove those computational assumptions. Rather, it cleanly exposes the exact bridge that a complete protocol proof must cross.

## Why the ideal world must be shared

The phrase “common ideal” carries the weight of the security argument. Suppose each real branch were close to a different ideal distribution. The first ideal might put nearly all its mass on one set of transcripts, while the second favors an entirely different set. Each local comparison could look excellent even though the two real branches remain easy to distinguish. Requiring one challenge-independent $I_k$ makes the hybrid paths meet.

There is also a subtle point in allowing $I_k$ to depend on the exposed static key $k$. Forward secrecy is evaluated after that key is revealed, so the ideal experiment need not pretend that the adversary lacks it. What must disappear is dependence on the old session’s challenge bit. This is precisely the separation one wants: compromise may disclose long-term state without retroactively disclosing which challenge-session secret was used.

The use of $\ell^1$ distance makes this geometry visible. Each distribution is a point in a finite-dimensional probability simplex. The two real views sit near the same ideal point, so they cannot be farther apart than the combined lengths of those two short paths. In the symmetric case, two paths of length at most $\varepsilon$ create a direct separation of at most $2\varepsilon$.

## Engineering lessons from a one-unit margin

The concrete inequality $12288<12289$ is both reassuring and cautionary. It proves the stated deterministic criterion with no room for an equality case, but its integer margin is only $1$. If the number of terms remained $1024$ while the bound rose from $3$ to $4$, the scaled worst case would become $16384$, and this certificate would fail. Likewise, adding even one more error term of magnitude $3$ gives $4\cdot1025\cdot3=12300$, already beyond the modulus.

Failure of the certificate would not mean every exchange fails. Errors can cancel, and probabilistic noise models often yield far smaller sums than the aligned worst case. It would mean only that the coordinate bound by itself no longer protects every possible vector. Designers must then choose among a larger modulus, fewer accumulated terms, tighter noise, a sharper structural analysis, or an explicitly quantified failure probability.

## What has—and has not—been established

The results form a compact chain. Bounded coordinate errors imply a bounded accumulated error. A strict inequality $4mB<q$ places that sum inside the reconciliation radius. For the concrete profile, the inequality is exactly $12288<12289$. Separately, finite post-compromise views obey an $\ell^1$ triangle inequality, so two LWE hybrid bounds to a common ideal imply a forward-secrecy bound equal to their sum.

These are rigorous structural guarantees, but they are not a full construction of Regev encryption, a worst-case lattice reduction, or an authenticated multi-session key exchange. Nor does the keyspace count establish a cryptanalytic work factor. Those larger claims require explicit algorithms, asymptotic security definitions, negligible functions, attack models, and concrete estimators.

That distinction is a strength rather than a weakness. Cryptographic confidence grows when each claim says exactly what it supports. Here the arithmetic tells us when noisy agreement succeeds; the probability geometry tells us how hybrid losses compose after compromise; and the parameter check shows both mechanisms operating at a familiar design scale. The resulting picture is simple enough to inspect and strong enough to serve as a foundation: noise can hide the secret, a narrow decoding zone can tame the noise, and a common ideal world can keep yesterday’s session opaque even after today’s long-term key is exposed.
