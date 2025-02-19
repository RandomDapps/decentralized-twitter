// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.2 <0.9.0;

library StringUtils {
    bytes constant private ALPHABET = "0123456789abcdefghijklmnopqrstuvwxyz";
    
    function generateUniqueId() internal view returns (string memory) {
        bytes32 hash = keccak256(
            abi.encodePacked(
                block.timestamp,    
                block.prevrandao,   
                msg.sender,        
                block.number,       
                gasleft()        
            )
        );
        
        bytes memory str = new bytes(12);  // Reduced from 16 to 12 characters
        uint256 hashVal = uint256(hash);
        
        for (uint256 i = 0; i < 12; i++) {
            // Use modulo directly on the hash value instead of bit shifting
            str[i] = ALPHABET[uint8(hashVal % 36)];
            hashVal /= 36;  // Divide by 36 for next iteration
        }
        
        return string(str);
    }
}