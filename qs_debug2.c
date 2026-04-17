#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <gmp.h>
#define MAX_FB 2000
#define MAX_REL 2500
typedef unsigned long long u64;

int main(int argc, char **argv) {
    if(argc<2) return 1;
    mpz_t N,s,Qx,tmp,g;
    mpz_init_set_str(N,argv[1],10);
    mpz_init(s);mpz_init(Qx);mpz_init(tmp);mpz_init(g);
    
    int bits=mpz_sizeinbase(N,2);
    int fb_target=(bits<=80)?60:(bits<=100)?150:(bits<=120)?400:800;
    int sieve_len=(bits<=80)?100000:(bits<=100)?300000:1000000;
    
    mpz_sqrt(s,N);
    if(mpz_mul(tmp,s,s),mpz_cmp(tmp,N)<0) mpz_add_ui(s,s,1);
    
    int fb[MAX_FB],r1[MAX_FB],r2[MAX_FB]; double logfb[MAX_FB]; int fb_sz=0;
    
    for(int p=3;fb_sz<fb_target&&p<100000;p+=2){
        int ip=1;for(int d=3;d*d<=p;d+=2) if(p%d==0){ip=0;break;}
        if(!ip)continue;
        long long nm=mpz_fdiv_ui(N,p);if(nm==0){printf("p=%d\n",p);return 0;}
        long long pw=1,b=nm;int e=(p-1)/2;
        while(e){if(e&1)pw=(pw*b)%p;b=(b*b)%p;e>>=1;}
        if(pw!=1)continue;
        int r;
        if(p%4==3){long long rb=nm;r=1;e=(p+1)/4;while(e){if(e&1)r=(int)(((long long)r*rb)%p);rb=(rb*rb)%p;e>>=1;}}
        else{r=-1;for(int t=1;t<p;t++)if(((long long)t*t)%p==nm){r=t;break;}if(r<0)continue;}
        long long sm=mpz_fdiv_ui(s,p);
        fb[fb_sz]=p;logfb[fb_sz]=log((double)p);
        r1[fb_sz]=(int)((r-sm+p)%p);r2[fb_sz]=(int)((p-r-sm+2*(long long)p)%p);
        if(r2[fb_sz]>=p)r2[fb_sz]-=p;
        fb_sz++;
    }
    printf("FB size=%d\n",fb_sz);
    
    double *sv=malloc(sieve_len*sizeof(double));
    int nrels=0,target=fb_sz+20;
    if(target>MAX_REL)target=MAX_REL;
    long long rel_xs[MAX_REL];int rel_nf[MAX_REL],rel_sg[MAX_REL];int *rel_fs[MAX_REL];
    
    for(int blk=0;nrels<target&&blk<100;blk++){
        long long x0=(long long)blk*sieve_len;
        for(int i=0;i<sieve_len;i++) sv[i]=0;
        for(int j=0;j<fb_sz;j++){
            int p=fb[j];double lp=logfb[j];
            int st1=(int)((r1[j]-(long long)(x0%p)+p)%p);
            int st2=(int)((r2[j]-(long long)(x0%p)+p)%p);
            for(int i=st1;i<sieve_len;i+=p)sv[i]+=lp;
            if(st1!=st2)for(int i=st2;i<sieve_len;i+=p)sv[i]+=lp;
        }
        double base_log=mpz_sizeinbase(N,2)*0.693/2.0+0.693;
        int cands=0;
        for(int i=0;i<sieve_len&&nrels<target;i++){
            long long xx=i+x0;
            double logQ=base_log+(xx>0?log((double)xx):0);
            if(sv[i]<logQ-logfb[fb_sz-1]*3)continue;
            cands++;
            mpz_set_si(Qx,xx);mpz_add(Qx,Qx,s);
            mpz_mul(Qx,Qx,Qx);mpz_sub(Qx,Qx,N);
            int sign=mpz_sgn(Qx)<0?1:0;
            mpz_abs(Qx,Qx);mpz_set(tmp,Qx);
            int fs[MAX_FB*2],nf=0;
            for(int j=0;j<fb_sz&&mpz_cmp_ui(tmp,1)>0;j++)
                while(mpz_divisible_ui_p(tmp,fb[j])){mpz_divexact_ui(tmp,tmp,fb[j]);fs[nf++]=j;}
            if(mpz_cmp_ui(tmp,1)==0){
                rel_xs[nrels]=xx+mpz_get_si(s);
                rel_nf[nrels]=nf;rel_sg[nrels]=sign;
                rel_fs[nrels]=malloc(nf*sizeof(int));
                memcpy(rel_fs[nrels],fs,nf*sizeof(int));
                nrels++;
            }
        }
        printf("Block %d: %d cands, %d rels (total %d)\n",blk,cands,(nrels-(blk>0?target:0)),nrels);
    }
    free(sv);
    printf("Total relations: %d (need %d)\n",nrels,fb_sz);
    
    mpz_clear(N);mpz_clear(s);mpz_clear(Qx);mpz_clear(tmp);mpz_clear(g);
    return 0;
}
