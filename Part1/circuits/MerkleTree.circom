pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**n];
    signal output root;

    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves
    component hash[2**(n-1)];
    component nextLevel;

    if(n == 0) {
        root <== leaves[0];
    } else {
        nextLevel = CheckRoot(n-1);
        for(var i=0; i<2**(n-1); i+=1){
            hash[i] = Poseidon(2);
            hash[i].inputs[0] <== leaves[i*2];
            hash[i].inputs[1] <== leaves[i*2+1];
            nextLevel.leaves[i] <== hash[i].out;
        }
        root <== nextLevel.out;
    }
}

template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    //[assignment] insert your code here to compute the root from a leaf and elements along the path
    component hash[n];
    for(var i=0; i<n; i+=1){
        hash[i] = Poseidon(2);
        var in0;
        var in1 = path_elements[i];

        if(i==0) {
            in0 = leaf;
        } else {
            in0 = hash[i-1].out;
        }

        hash[i].inputs[0] <== in0 - (in0-in1)*path_index[i];
        hash[i].inputs[1] <== in1 + (in0-in1)*path_index[i];
    }
    root <== hash[n-1].out;
}