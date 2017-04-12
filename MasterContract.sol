pragma solidity ^0.4.9;

import "./SoundToken.sol";
import "./ERC23Interface.sol";

contract MasterContract {
    
    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }
    
    struct License {
        address assignedToken;
        bytes32 licenseSig;
        mapping (bytes32 => uint256) trackPrice;
    }
    
    mapping (address => bool) public trackToken;
    mapping (bytes32 => License) licenses;
    mapping (bytes32 => bytes32) trackLicense;
    address public owner;
    address public SOCHContract;
    
    function MasterContract() {
        owner = msg.sender;
    }
    
    function trackListened(bytes32 _trackSig, uint256 _times) onlyOwner {
        if(trackToken[licenses[trackLicense[_trackSig]].assignedToken]) {
            ERC23 asset = ERC23(SOCHContract);
            if(!asset.transfer(licenses[trackLicense[_trackSig]].assignedToken, _times * licenses[trackLicense[_trackSig]].trackPrice[_trackSig])) {
                throw;
            }
        }
    }
    
    function createTrackToken(uint256 _initialSupply, string _name, string _symbol, int _decimals) onlyOwner returns (address newToken) {
        newToken = new SoundTokens(_initialSupply, _name, _symbol, _decimals);
        trackToken[newToken]=true;
    }
    
    function registerTrack(bytes32 _trackSig, bytes32 _licenseSig, uint256 _price) onlyOwner {
        licenses[_licenseSig].trackPrice[_trackSig] = _price;
        trackLicense[_trackSig] = _licenseSig;
    }
    
    function updateTrackPrice(bytes32 _trackSig, uint256 _price) onlyOwner {
        licenses[trackLicense[_trackSig]].trackPrice[_trackSig] = _price;
    }
    
    
    // Creates an empty license with no token contract assigned
    function createLicense(bytes32 _licenseSig) onlyOwner {
        licenses[_licenseSig].licenseSig = _licenseSig;
    }
    
    function createLicense(bytes32 _licenseSig, uint256 _initialSupply, string _name, string _symbol, int _decimals) onlyOwner returns (address _assignedToken) {
        licenses[_licenseSig].licenseSig = _licenseSig;
        licenses[_licenseSig].assignedToken = createTrackToken(_initialSupply, _name, _symbol, _decimals);
    }
    
    function getTrackLicense(bytes32 _trackSig) constant returns (bytes32 _license){
        return trackLicense[_trackSig];
    }
    
    function getTrackPrice(bytes32 _trackSig) constant returns (uint256 _price){
        return licenses[trackLicense[_trackSig]].trackPrice[_trackSig];
    }
}