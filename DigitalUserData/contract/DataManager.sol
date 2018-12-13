pragma solidity ^ 0.4.17;

contract DataManager{
    
    uint businessId;
    string brandName; 
    uint32 brandImageHash;
    
    struct business{
        string businessName;
        string businessAddress; 
        string businessCity; 
        string businessState;
        string businessCountryCode;
        string businessZipCode;
    }
    
    struct brand{
        uint businessId; 
        string additionalParametersJson; //includes : uint brandSerialId, uint256 startDate, string classList, string brandDescription, string brandUseLocation
        bool isUsed; 
        bool isLive;
        uint256 expiredOn;
    }
    
    struct brandImage{
        string brandName;
        string imageTitle;
        string imageDescription;
    }
    
    mapping(uint => business) businesses; 
    mapping(uint => bool) isBusinessRegistered; 
    mapping(string => brand) brands;
    mapping(string => bool) isBrandRegistered;
    mapping(uint32 => brandImage) brandImages;
    mapping(uint32 => bool) isBrandImageRegistered;
    
    event BusinessEvent(string _actionPerformed, uint _businessId, string _businessName, string _businessAddress, string _businessCity, string _businessState, string _businessCountryCode, string _businessZipCode, uint256 _timestamp);
    event BrandEvent(string _actionPerformed, uint _businessId, string _brandName,  string _additionalParametersJson, bool _isUsed, bool _isLive, uint256 _expiredOn, uint256 _timestamp);
    event BrandImageEvent(string _actionPerformed, string _brandName, uint32 _brandImageHash, string _imageTitle, string _imageDescription, uint256 _timestamp);
    
    function registerBusiness(uint _businessId, string _businessName, string _businessAddress, string _businessCity, string _businessState, string _businessCountryCode, string _businessZipCode){
        require(isBusinessRegistered[_businessId] == false);
        businesses[_businessId].businessName = _businessName;
        businesses[_businessId].businessAddress = _businessAddress;
        businesses[_businessId].businessCity = _businessCity;
        businesses[_businessId].businessState = _businessState;
        businesses[_businessId].businessCountryCode = _businessCountryCode;
        businesses[_businessId].businessZipCode = _businessZipCode;
        isBusinessRegistered[_businessId] = true;
        
        BusinessEvent("REGISTERED", _businessId, _businessName, _businessAddress, _businessCity, _businessState, _businessCountryCode, _businessZipCode, now);
    }
    
    function updateBusiness(uint _businessId, string _businessName, string _businessAddress, string _businessCity, string _businessState, string _businessCountryCode, string _businessZipCode){
        require(isBusinessRegistered[_businessId] == true);
        businesses[_businessId].businessName = _businessName;
        businesses[_businessId].businessAddress = _businessAddress;
        businesses[_businessId].businessCity = _businessCity;
        businesses[_businessId].businessState = _businessState;
        businesses[_businessId].businessCountryCode = _businessCountryCode;
        businesses[_businessId].businessZipCode = _businessZipCode;
        
        BusinessEvent("UPDATED", _businessId, _businessName, _businessAddress, _businessCity, _businessState, _businessCountryCode, _businessZipCode, now);
    }
    
    function getBusinessDetails(uint _businessId) returns(string, string, string, string, string, string){
        if(isBusinessRegistered[_businessId] == true)
        return (businesses[_businessId].businessName, businesses[_businessId].businessAddress, businesses[_businessId].businessCity, businesses[_businessId].businessState, businesses[_businessId].businessCountryCode, businesses[_businessId].businessZipCode);
        else
        return ("null", "null", "null", "null", "null", "null");
    }
    
    function registerBrand(string _brandName, uint _businessId, string _additionalParametersJson){
        require(isBrandRegistered[_brandName] == false && isBusinessRegistered[_businessId] == true);
        brands[_brandName].businessId = _businessId;
        brands[_brandName].additionalParametersJson = _additionalParametersJson;
        brands[_brandName].isUsed = false;
        brands[_brandName].isLive = true;
        brands[_brandName].expiredOn = 0; 
        isBrandRegistered[_brandName] = true;
        
        BrandEvent("REGISTERED", _businessId, _brandName, _additionalParametersJson, brands[_brandName].isUsed, brands[_brandName].isLive, brands[_brandName].expiredOn, now);
    }
    
    function updateBrand(string _brandName, uint _businessId, string _additionalParametersJson){
        require(isBrandRegistered[_brandName] == true);
        brands[_brandName].businessId = _businessId;
        
        BrandEvent("UPDATED", _businessId, _brandName, _additionalParametersJson, brands[_brandName].isUsed, brands[_brandName].isLive, brands[_brandName].expiredOn, now);
    }
    
    function destroyBrand(string _brandName){
        require(isBrandRegistered[_brandName] == true);
        brands[_brandName].isLive = false;
        brands[_brandName].expiredOn = now; 
        
        BrandEvent("DESTROYED", brands[_brandName].businessId, _brandName, brands[_brandName].additionalParametersJson, brands[_brandName].isUsed, brands[_brandName].isLive, brands[_brandName].expiredOn, now);
    }
   
    function getBrandDetails(string _brandName) returns(uint, string, bool, bool, uint256){
        if(isBrandRegistered[_brandName] == true)
        return (brands[_brandName].businessId, brands[_brandName].additionalParametersJson, brands[_brandName].isUsed, brands[_brandName].isLive, brands[_brandName].expiredOn);
        else
        return (0, "null", false, false, 0);
    }
    
    function registerBrandImage(uint32 _brandImageHash, string _brandName, string _imageTitle, string _imageDescription){
        require(isBrandImageRegistered[_brandImageHash] == false && isBrandRegistered[_brandName] == true);
        brandImages[_brandImageHash].brandName = _brandName;
        brandImages[_brandImageHash].imageTitle = _imageTitle;
        brandImages[_brandImageHash].imageDescription = _imageDescription;
        isBrandImageRegistered[_brandImageHash] = true;
        brands[_brandName].isUsed = true;
        
        BrandImageEvent("REGISTERED", _brandName, _brandImageHash, _imageTitle, _imageDescription, now);
        BrandEvent("UPDATED", brands[_brandName].businessId, _brandName, brands[_brandName].additionalParametersJson, brands[_brandName].isUsed, brands[_brandName].isLive, brands[_brandName].expiredOn, now);
    }
    
    function updateBrandImage(uint32 _brandImageHash, string _brandName, string _imageTitle, string _imageDescription){
        require(isBrandImageRegistered[_brandImageHash] == true);
        brandImages[_brandImageHash].brandName = _brandName;
        brandImages[_brandImageHash].imageTitle = _imageTitle;
        brandImages[_brandImageHash].imageDescription = _imageDescription;
        
        BrandImageEvent("UPDATED", _brandName, _brandImageHash, _imageTitle, _imageDescription, now);
    }
    
    function getBrandImageDetails(uint32 _brandImageHash) returns(string, string, string){
        if(isBrandImageRegistered[_brandImageHash] == true)
        return (brandImages[_brandImageHash].brandName, brandImages[_brandImageHash].imageTitle, brandImages[_brandImageHash].imageDescription);
        else
        return ("null", "null", "null");
    }
}



