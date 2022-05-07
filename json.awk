#!/bin/awk -f

BEGIN {
    FS="\n"
    k_index=0
    o_index=0
}

{
    gsub("[\" ]|^.|.$","",$0)
    gsub("}\\]?,?","}\n",$0)
    gsub(",","\n",$0)
    gsub("\\[?{", "{\n", $0)

    for(i=1;i<NF;i++){
        if(match($i, "(.*?):.*{", g)) {
            key[k_index++] = g[1]
        }else if($i ~ /\}/) {
            delete key[--k_index]
        }else{
            line=""        
            k_len=length(key)
            for(j=0;j<k_len;j++){
                line=line key[j]
                if(j!=len-1)
                    line=line "."
            }
            line=line $i
            out[o_index++] = line
        }
    }
}

END {
    flag=0
    l_length=length(out)
    for(k=0;k<l_length;k++){
        if(match(out[k], path":(.*)", g)){
            flag=1
            print g[1]
        }
    }
    if(!flag)
        print("Unknown path.")
}