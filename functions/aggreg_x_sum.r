aggreg_x_sum = function(x,ne,...){xm = tapply(x, rep(1:(length(x)/ne), each = ne), sum, ...);return(xm)}
