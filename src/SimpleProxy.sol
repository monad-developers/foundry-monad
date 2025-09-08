// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract SimpleProxy {
    // Storage slot for implementation address
    // keccak256("IMPLEMENTATION_SLOT") - 1
    bytes32 private constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
    
    // Storage slot for admin address
    // keccak256("ADMIN_SLOT") - 1
    bytes32 private constant ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;
    
    // Events
    event ImplementationChanged(address newImplementation);
    event AdminChanged(address newAdmin);
    
    // Modifier to check if caller is admin
    modifier onlyAdmin() {
        require(msg.sender == getAdmin(), "Not the admin");
        _;
    }
    
    constructor(address _implementation, address _admin) {
        _setImplementation(_implementation);
        _setAdmin(_admin);
    }
    
    // Fallback function - delegates all calls to implementation
    fallback() external payable {
        _delegate();
    }
    
    // Receive function for ETH transfers
    receive() external payable {
        _delegate();
    }
    
    // Get current implementation address
    function getImplementation() external view returns (address) {
        return _getImplementation();
    }
    
    // Get current admin address
    function getAdmin() public view returns (address) {
        return _getAdmin();
    }
    
    // Upgrade to new implementation (only admin)
    function upgrade(address newImplementation) external onlyAdmin {
        _setImplementation(newImplementation);
        emit ImplementationChanged(newImplementation);
    }
    
    // Change admin (only current admin)
    function changeAdmin(address newAdmin) external onlyAdmin {
        require(newAdmin != address(0), "Invalid admin address");
        _setAdmin(newAdmin);
        emit AdminChanged(newAdmin);
    }
    
    // Internal function to delegate calls
    function _delegate() internal {
        address implementation = _getImplementation();
        require(implementation != address(0), "No implementation set");
        
        assembly {
            // Copy calldata to memory
            calldatacopy(0, 0, calldatasize())
            
            // Delegate call to implementation
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)
            
            // Copy return data to memory
            returndatacopy(0, 0, returndatasize())
            
            // Return or revert based on result
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }
    
    // Internal function to get implementation address
    function _getImplementation() internal view returns (address implementation) {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            implementation := sload(slot)
        }
    }
    
    // Internal function to set implementation address
    function _setImplementation(address implementation) internal {
        require(implementation != address(0), "Invalid implementation address");
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            sstore(slot, implementation)
        }
    }
    
    // Internal function to get admin address
    function _getAdmin() internal view returns (address admin) {
        bytes32 slot = ADMIN_SLOT;
        assembly {
            admin := sload(slot)
        }
    }
    
    // Internal function to set admin address
    function _setAdmin(address admin) internal {
        bytes32 slot = ADMIN_SLOT;
        assembly {
            sstore(slot, admin)
        }
    }
} 