# Secrets in the Shape of a Curve

## How polynomial geometry lets a group share power without surrendering privacy

A locked vault usually has one key. That arrangement is simple, but brittle: lose the key and the vault is sealed forever; copy it and any holder can act alone. Modern organizations often need a subtler rule. A hospital may want several senior staff members to approve access to an emergency archive. A company may want its recovery key distributed across offices. A digital-asset custodian may want no single employee to control a treasury.

Threshold secret sharing replaces one all-powerful key with many individually useless fragments. Choose a threshold $t$. Any $t$ participants can recover the secret, but any group of only $t-1$ participants learns nothing about it. The phrase “learns nothing” is unusually strong here: it does not merely mean that guessing is computationally expensive. It means that every possible secret remains exactly compatible with the observed fragments.

The mechanism behind this feat is a familiar object from algebra: a polynomial.

## A secret becomes an intercept

Work in a field $F$, such as the integers modulo a prime. The dealer chooses a secret $s\in F$ and constructs a polynomial

$$
p(X)=s+a_1X+a_2X^2+\cdots+a_{t-1}X^{t-1}.
$$

The coefficients $a_1,\ldots,a_{t-1}$ are chosen at random. Participant $i$ receives a public nonzero location $x_i$ together with the private value $p(x_i)$. This pair is a share. The secret is hidden at the special location $0$, because $p(0)=s$.

Why does the threshold equal $t$? A polynomial of degree less than $t$ is uniquely determined by its values at $t$ distinct points. Thus $t$ valid shares determine the whole polynomial by interpolation, and in particular determine $p(0)$. The standard Lagrange formula makes reconstruction explicit. Given distinct locations $x_1,\ldots,x_t$ and values $y_i=p(x_i)$,

$$
p(X)=\sum_{i=1}^{t}y_i\prod_{j\ne i}\frac{X-x_j}{x_i-x_j}.
$$

Setting $X=0$ recovers the secret directly:

$$
s=p(0)=\sum_{i=1}^{t}y_i\prod_{j\ne i}\frac{-x_j}{x_i-x_j}.
$$

All arithmetic occurs in $F$. No exhaustive search is involved.

## Why one missing share changes everything

Reconstruction explains why $t$ shares are enough. Privacy requires the complementary fact: $t-1$ shares are not merely inconvenient but perfectly uninformative.

Suppose an observer knows values at a set $A$ of $t-1$ distinct nonzero locations. Pick any proposed secret $s\in F$. Add the point $(0,s)$ to those observations. There are now exactly $t$ distinct prescribed points, so interpolation produces one and only one polynomial of degree less than $t$ passing through all of them.

This yields the **Perfect Privacy Extension Theorem**: for any $t-1$ distinct nonzero observation points, any prescribed values at those points, and any candidate secret $s$, there exists exactly one polynomial of degree less than $t$ whose value at $0$ is $s$ and whose observed values are the prescribed ones.

The theorem turns privacy into geometry. Imagine that two conspirators hold two points from a quadratic sharing scheme, where $t=3$. Infinitely many ordinary parabolas pass through two real points; over a finite field, a finite family does. Choosing a possible intercept selects exactly one member of that family. Every intercept is represented. The observed points therefore cannot favor one secret over another.

When the random coefficients are sampled uniformly over a finite field, the uniqueness is also a counting argument. For each fixed transcript of $t-1$ shares and each secret, exactly one coefficient tuple produces that transcript. Hence the transcript has the same probability for every secret. The privacy is information-theoretic: it survives unlimited computing power.

A useful corollary is the **No-Exclusion Theorem**. Given any observations at $t-1$ allowed locations and any two candidate secrets $s_1$ and $s_2$, there is a valid sharing polynomial for $s_1$ matching all observations and another valid sharing polynomial for $s_2$ matching the same observations. Nothing in the transcript can rule out either candidate.

## The threshold is exact, not conservative

Could fewer than $t$ shares sometimes suffice because the degree bound is known? In general, no. Let the degree limit be $d=t-1$, and suppose only $d$ distinct nonzero locations form a set $A$. Consider

$$
r(X)=\prod_{a\in A}(X-a).
$$

This polynomial has degree $d$ and vanishes at every supplied location. The zero polynomial and $r$ therefore produce identical shares there. Yet their secrets differ, because

$$
r(0)=\prod_{a\in A}(-a)\ne 0,
$$

as every $a$ is nonzero. Thus $d$ shares can correspond to two different secrets.

Together with interpolation, this proves the **Exact Reconstruction Threshold Theorem**: values at $d+1$ distinct locations uniquely determine every polynomial of degree at most $d$, while at $d$ nonzero locations uniqueness can fail, even at the secret point $0$. The “plus one” in the threshold is not a safety margin. It is forced by algebra.

There is another concise proof of sufficiency. If two degree-at-most-$d$ polynomials agree at $d+1$ distinct locations, their difference has at least $d+1$ roots. A nonzero polynomial of degree at most $d$ cannot have that many roots. Their difference must therefore be zero.

## Privacy does not guarantee honesty

The basic scheme assumes the dealer distributes values from one polynomial. A malicious or faulty dealer could instead send inconsistent shares. Different groups might then reconstruct different answers. Privacy remains meaningful, but reliability collapses.

Feldman’s verifiable variant adds public commitments to the polynomial coefficients. To describe its algebra cleanly, let $C:F\to G$ be an additive homomorphism from the coefficient field into an abelian group $G$. In conventional multiplicative notation, $C(a)$ is analogous to $g^a$; group addition here plays the role of multiplying commitments. If

$$
p(X)=\sum_i a_iX^i,
$$

the dealer publishes $C(a_i)$ for every nonzero coefficient position. A participant at location $x$ who receives a claimed share $y$ checks

$$
C(y)=\sum_i C(a_i x^i).
$$

Because $C$ preserves addition, the genuine evaluation always passes:

$$
C(p(x))=C\!\left(\sum_i a_ix^i\right)=\sum_i C(a_ix^i).
$$

This is the **Honest Verification Theorem**: every true share of the committed polynomial satisfies the public verification equation.

For soundness, assume that $C$ is injective on the relevant coefficient domain. If a claimed share $y$ passes, then its commitment equals the commitment of $p(x)$. Injectivity forces $y=p(x)$. We obtain the **Cheating Detection Theorem**: under an injective commitment map, every altered share fails verification; equivalently, every accepted share is exactly the committed polynomial’s value at that location.

This conclusion is algebraic rather than probabilistic. There is no small chance that a bad value slips through under the stated assumption. Acceptance itself is a certificate of consistency.

Finally, combine verification with interpolation. Suppose a committed polynomial and a candidate polynomial both have degree at most $d$. If the candidate’s evaluations pass the committed verification equation at $d+1$ distinct locations, injectivity says the two polynomials agree at each location. The root-counting argument then says they are identical. This is the **Accepted-Share Reconstruction Theorem**: $d+1$ accepted shares reconstruct the unique committed polynomial and therefore its committed secret.

## A small example

Take the field of integers modulo $17$, threshold $t=3$, and secret $5$. Let

$$
p(X)=5+7X+3X^2\pmod {17}.
$$

At locations $1$, $2$, and $3$, the shares are

$$
p(1)=15,\qquad p(2)=14,\qquad p(3)=2\pmod {17}.
$$

Any three recover $p(0)=5$. But suppose only the first two values are visible. Every proposed secret in $\{0,1,\ldots,16\}$ determines a unique quadratic-or-lower polynomial through $(0,s)$, $(1,15)$, and $(2,14)$. All seventeen secrets remain possible.

For a transparent verification demonstration, use the injective additive commitment $C(a)=4a\pmod {17}$. The claim at $x=2$ is $14$, and

$$
C(14)=4\cdot14=5\pmod {17}.
$$

The committed evaluation gives

$$
C(5)+C(7\cdot2)+C(3\cdot2^2)=3+5+14=5\pmod {17},
$$

so the true share passes. Changing the claim to $15$ changes its commitment to $9$, and verification fails.

## Distributed trust as a mathematical shape

These results separate three guarantees that are often blurred together. Privacy says that fewer than the threshold reveal no information. Reconstruction says that enough correct shares determine one answer. Verifiability says that accepted shares belong to the publicly committed polynomial. Each guarantee has its own short algebraic reason: interpolation, root bounds, and injectivity.

The practical attraction is broad. Threshold sharing can protect backup keys, distribute authority among trustees, support recovery procedures, and remove single points of compromise. Verifiable sharing strengthens multiparty protocols in which participants cannot simply trust the dealer. The mathematics does not decide who should hold shares or how devices should be secured, but it supplies a precise foundation for those systems.

The guarantees also compose cleanly with organizational policy. A seven-member board might choose a threshold of four, allowing business to continue despite three absences while preventing any trio from acting alone. A geographically distributed recovery service can place shares in independent jurisdictions, so that one damaged site or compromised operator is insufficient. The algebra treats these stories identically: identities become distinct nonzero field locations, and authorization becomes the number of evaluations available. Real deployments must additionally protect the private channels, authenticate participants, sample coefficients securely, and account for maliciously missing shares. Those engineering duties do not replace the theorems; they establish the conditions under which the theorems describe the deployed system.

A secret, in this view, is not chopped into recognizable pieces. It is concealed as one coordinate of a curve. Too few points leave every intercept possible; enough points bring the curve into focus; and public coefficient commitments ensure that everyone is looking at the same curve. That is the central elegance of polynomial secret sharing: access, privacy, and consistency emerge from the geometry of interpolation.