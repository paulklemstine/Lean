# One Witness for a Square Root of Possibilities

## A hidden perfect square in the geometry of networks

A large network can carry more than traffic. It can carry *chips*: integer amounts placed at vertices, moved along edges by a balancing operation called chip-firing. Two chip configurations, or **divisors**, are regarded as equivalent when one can be transformed into the other by these local moves. This simple game opens onto a graph-theoretic analogue of algebraic geometry. Degree records the total number of chips, while rank measures how robustly a divisor can meet prescribed demands.

The central question is an existence problem. Given a graph of genus $g$, how many chips are needed to obtain a divisor of rank at least $r$? The graph genus is its cycle surplus: for a connected graph with $n$ vertices and $m$ edges,

$$
 g=m-n+1.
$$

The larger $g$ is, the more independent cycles the network possesses and the richer its divisor theory becomes.

Brill–Noether theory packages the expected answer into one integer. For integers $g$, $r$, and $d$, define the **Brill–Noether number**

$$
\rho(g,r,d)=g-(r+1)(g-d+r).
$$

A nonnegative value is the familiar numerical signal that divisors of degree $d$ and rank $r$ should exist. At first sight, the formula mixes three parameters in an awkward way. But at one special degree it collapses into a perfect square.

The special value is $d=g-1$, often called the half-canonical degree because the canonical degree is $2g-2$. Substitution gives the exact identity

$$
\rho(g,r,g-1)=g-(r+1)^2.
$$

This is the **Half-Canonical Square Identity**. Its proof is a single line of algebra: $g-(g-1)+r=r+1$, so the product in the definition becomes $(r+1)^2$. Yet this elementary simplification changes the architecture of the existence problem.

The condition $\rho(g,r,g-1)\ge 0$ is now equivalent to

$$
(r+1)^2\le g.
$$

Thus the admissible ranks are precisely the lattice points lying below a square-root threshold. Instead of wrestling with the full Brill–Noether expression, one can read the entire range from $\sqrt g$: the largest admissible rank is $\lfloor\sqrt g\rfloor-1$ when $g$ is a perfect square, and more uniformly it is $\lfloor\sqrt g-1\rfloor$.

## Regular graphs turn the square into network data

Now suppose every vertex of a finite connected graph has the same degree $k$. Such a graph is **$k$-regular**. The handshaking identity says that $2m=nk$, because every edge contributes two incidences. Therefore

$$
2(g-1)=2(m-n)=n(k-2).
$$

Equivalently,

$$
g=\frac{n(k-2)}2+1.
$$

Combining this genus formula with the square identity yields the **Regular-Graph Quadratic Criterion**: whenever $g\ge 1$ and $2(g-1)=n(k-2)$,

$$
\rho(g,r,g-1)\ge 0
\quad\Longleftrightarrow\quad
2(r+1)^2\le n(k-2)+2.
$$

This translation is valuable because the right-hand side mentions only the visible size and valency of the network. For fixed $k$, the relevant ranks grow on the order of $\sqrt n$, not $n$. A random regular graph may have millions of vertices, but the rank range demanded at half-canonical degree occupies a square-root-sized window.

Consider a $6$-regular graph on $50$ vertices. Its genus is

$$
g=\frac{50(6-2)}2+1=101.$$

The admissibility condition is $(r+1)^2\le101$, so $r$ may range from $0$ through $9$. The apparently separate demands for ten ranks are all controlled by one threshold near $\sqrt{101}$.

## The one-witness principle

The decisive step is to replace a family of constructions by a single certificate.

Fix a positive integer scale factor $C$. Say that a divisor $D$ provides a **square-root rank certificate** if

$$
\deg(D)\le C(g-1)
$$

and

$$
g\le\bigl(C\,\operatorname{rank}(D)+1\bigr)^2.
$$

The first inequality controls cost: the divisor uses at most a constant multiple of the half-canonical budget. The second says that its scaled rank reaches the square-root frontier.

The target property is **scaled half-canonical existence**: for every nonnegative integer $r$ satisfying $\rho(g,r,g-1)\ge0$, there should be a divisor $D_r$ such that

$$
\deg(D_r)\le C(g-1)
\qquad\text{and}\qquad
r\le C\,\operatorname{rank}(D_r).
$$

The second inequality is an integer-safe version of $\operatorname{rank}(D_r)\ge r/C$.

The **Square-Root Certificate Theorem** says that one certificate proves this property for every admissible $r$. Indeed, admissibility gives

$$
(r+1)^2\le g,
$$

while the certificate gives

$$
g\le\bigl(C\,\operatorname{rank}(D)+1\bigr)^2.
$$

Chaining them yields

$$
(r+1)^2\le\bigl(C\,\operatorname{rank}(D)+1\bigr)^2.
$$

Both sides are squares of nonnegative integers, so taking square roots preserves order:

$$
r+1\le C\,\operatorname{rank}(D)+1.
$$

After subtracting $1$, we obtain $r\le C\,\operatorname{rank}(D)$. The very same divisor $D$ works for every admissible rank. No list of witnesses is required.

This is more than a shorter proof. It is a compression principle. A universal statement indexed by all ranks beneath $\sqrt g$ is reduced to one controlled-degree object whose rank reaches the endpoint.

## From individual networks to random ones

Random regular graphs are useful models for communication networks, error-correcting structures, and sparse expanders. For fixed $k\ge5$, choose a simple $k$-regular graph uniformly among those on $n$ vertices, with $n$ restricted to values for which such graphs exist. Its genus is

$$
g=n\left(\frac{k}{2}-1\right)+1.
$$

The asymptotic goal is to find a constant $C_k>0$ such that, with probability tending to $1$ as $n\to\infty$, every half-canonical admissible rank is served by a divisor of degree at most $C_k(g-1)$ and rank at least $r/C_k$.

The square-root theorem identifies exactly what remains to establish this probabilistic statement. It is enough to show that, with high probability, each sampled graph carries one divisor $D$ satisfying

$$
\deg(D)\le C_k(g-1),
\qquad
g\le\bigl(C_k\,\operatorname{rank}(D)+1\bigr)^2.
$$

Once that event occurs, the deterministic theorem supplies the entire rank range on that outcome. If every outcome in an event has such a certificate, then every outcome in the same event has scaled half-canonical existence. Consequently, probabilities transfer without loss: the probability of the desired existence property is at least the probability of the certificate event.

This pointwise-to-random transfer is conceptually clean. The arithmetic does not need to know how the random graph was generated. Expansion estimates, spectral gaps, energy pairings, or covering-radius bounds may be used to build the witness; after that, the square identity performs the propagation.

The present result is therefore a reduction, not by itself a proof that random regular graphs possess the needed certificates with high probability. Its force lies in isolating the analytic target sharply enough that probabilistic graph theory can attack one inequality rather than a moving family of rank conditions.

## A second kind of universal graph property

There is a useful parallel in graph coloring. A graph is called **$q$-choosable** if, whenever each vertex $v$ receives a finite list $L(v)$ of at least $q$ allowed natural-number colors, one can select a color $c(v)\in L(v)$ at every vertex so that adjacent vertices receive different colors.

Choosability and scaled divisor existence share a logical shape: both demand successful choices against an entire family of inputs. Choosability ranges over all sufficiently large color lists; half-canonical existence ranges over all admissible ranks. The square-root certificate theorem shows that the latter universal demand has an endpoint certificate. This comparison suggests a broad computational theme: when a graph property quantifies over many requests, search for a monotone extremal witness that answers them all.

## A small table with a large lesson

The threshold can be seen without any advanced machinery. At genus $g=25$, admissibility permits $r=0,1,2,3,4$, because $(4+1)^2=25$. At genus $g=26$, the list does not change: rank $5$ would require $(5+1)^2=36$. Only when the genus reaches $36$ does a new rank enter. The admissible range therefore grows in plateaus, with jumps at perfect squares.

This staircase behavior explains why squared inequalities are preferable to decimal approximations. A calculator might display a rounded value of $\sqrt g$ near an integer and obscure which side of the boundary one occupies. The test $(r+1)^2\le g$ never does. It also shows precisely how much additional cycle complexity is required to request one more unit of rank: advancing from $r$ to $r+1$ moves the threshold from $(r+1)^2$ to $(r+2)^2$, a gap of $2r+3$.

The certificate has the same staircase character. If $q=\operatorname{rank}(D)$, then its reach is governed by $(Cq+1)^2$. Improving rank by one expands the certified genus ceiling from $(Cq+1)^2$ to $(C(q+1)+1)^2$, an increase of $2C(Cq+1)+C^2$. This quantifies the leverage gained from a modest rank improvement.

## Why the square root matters

Square-root laws often signal a boundary between abundance and obstruction. In probability they govern fluctuations; in geometry they convert area into length; in algorithms they frequently mark a reduced search scale. Here the square root emerges exactly, not asymptotically, because the half-canonical substitution turns the Brill–Noether count into a square.

That exactness matters computationally. Testing admissibility requires only integer arithmetic: compute $(r+1)^2$ and compare it with $g$. No floating-point square root is needed. Testing a certificate is equally direct: check one degree inequality and one squared-rank inequality. For a fixed graph, enumerating every admissible rank takes $O(\sqrt g)$ steps, but the certificate check itself takes constant many arithmetic comparisons. With fast integer arithmetic, the bit cost is governed by multiplication of numbers of size $O(\log g)$.

The pathway ahead is now explicit. First derive $2(g-1)=n(k-2)$ for connected regular graphs. Then relate chip-firing rank to a Laplacian energy pairing or covering radius. Next deduce the needed bound from expansion or a spectral gap. Finally invoke high-probability expansion results for random regular graphs and optimize $C_k$.

The key conceptual gain has already occurred: the many-rank Brill–Noether problem at degree $g-1$ has been folded into one square-root endpoint. A perfect square, hidden in a dimension count, turns a chorus of existence questions into a solo.