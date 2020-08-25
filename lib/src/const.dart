part of imena;

class ImenaAPIConst {
  static const COMMAND_LOGIN = 'authenticateResellerUser';
  static const COMMAND_LOGOUT = 'invalidateAuthToken';
  static const COMMAND_TOKEN_INFO = 'getAuthTokenInfo';
  static const COMMAND_DOMAINS_LIST = 'getDomainsList';
  static const COMMAND_DOMAIN_INFO = 'getDomain';
  static const COMMAND_DOMAIN_INFO_SHORT = 'getDomainInfoByName';
  static const COMMAND_SET_NS = 'editDomainNameserversList';
  static const COMMAND_SET_NS_DEFAULT = 'setDomainNameserversToDefault';
  static const COMMAND_SET_NS_DNSHOSTING = 'setDomainNameserversToDnshosting';
  static const COMMAND_SET_NS_MIROHOST = 'setDomainNameserversToMirohost';
  static const COMMAND_ADD_CHILD_NS = 'addDomainChildNameserver';
  static const COMMAND_DEL_CHILD_NS = 'deleteDomainChildNameserver';
  static const COMMAND_UPD_CONTACT = 'editDomainContact';
  static const COMMAND_SET_PRIVACY = 'setDomainPrivacy';
  static const COMMAND_CREATE_RENEW_PAYMENT = 'createDomainRenewPayment';
  static const COMMAND_CREATE_RENEW_ORDER = 'createDomainRenewOrder';
  static const COMMAND_CANCEL_RENEW_ORDER = 'cancelDomainRenewOrder';
  static const COMMAND_CREATE_REGISTRATION_PAYMENT = 'createDomainRegistrationPayment';
  static const COMMAND_CREATE_REGISTRATION_ORDER = 'createDomainRegistrationOrder';
  static const COMMAND_CREATE_TRANSFER_PAYMENT = 'createDomainTransferPayment';
  static const COMMAND_CREATE_TRANSFER_ORDER = 'createDomainTransferOrder';
  static const COMMAND_DELETE_ORDER = 'deleteDomainOrder';
  static const COMMAND_PAYMENT_STATUS = 'getResellerPaymentStatus';
  static const COMMAND_RESELLER_BALANCE = 'getResellerBalance';
  static const COMMAND_RESELLER_PRICES = 'getResellerPrices';

  static const COMMAND_CREATE_CLIENT = 'createClient';
  static const COMMAND_CLIENT_INFO = 'getClient';
  static const COMMAND_CLIENT_LIST = 'getResellerClientsList';
  static const COMMAND_PICK_DOMAIN = 'pickDomainForReseller';
  static const COMMAND_GET_AUTH_CODE = 'initOutgoingDomainTransfer';
  static const COMMAND_INTERNAL_TRANSFER = 'internalDomainTransfer';

  static const CONTACT_ADMIN = 'admin-c';
  static const CONTACT_TECH = 'tech-c';
  static const CONTACT_OWNER = 'owner-c';
  static const CONTACT_BILLING = 'owner-c';

  static const HOSTING_TYPE_MIROHOST = 'mirohost';
  static const HOSTING_TYPE_DNS = 'dnshosting';
  static const HOSTING_TYPE_DEFAULTS = 'default';

  static const PAYMENT_STATUS_NEW = 'new';
  static const PAYMENT_STATUS_PROCESS = 'inProcess';
  static const PAYMENT_STATUS_SUCCESS = 'success';
  static const PAYMENT_STATUS_RETURNED = 'returned';
  static const PAYMENT_STATUS_DELETED = 'deleted';

  static const SECOND_AUTH_SMS = 'sms';
  static const SECOND_AUTH_GOOGLE = 'google';

  static const ORDER_TYPE_ADD = 'add';
  static const ORDER_TYPE_TRANSFER = 'transfer';

  static const PAYMENT_TYPE_ADD = 'add';
  static const PAYMENT_TYPE_TRANSFER = 'transfer';
  static const PAYMENT_TYPE_RENEW = 'renew';

  static const PICK_FILTER_ALL = 'all';
  static const PICK_FILTER_AVAILABLE = 'available';
  static const PICK_FILTER_UNAVAILABLE = 'unavailable';
  static const PICK_FILTER_REGISTERED = 'registered';
  static const PICK_FILTER_RESERVED = 'reserved';
  static const PICK_FILTER_MIRRORED = 'mirrored';
  static const PICK_FILTER_SALE = 'on_sale';
  static const PICK_FILTER_UNKNOWN = 'unknown';

  static const LANG_UA = 'ua';
  static const LANG_RU = 'ru';
  static const LANG_EN = 'en';

  static const CLIENT_TYPE_INDIVIDUAL = 'individual';
  static const CLIENT_TYPE_SOLE_PROPRIETOR = 'sole proprietor';
  static const CLIENT_TYPE_LEGAL_ENTITY = 'legal entity';
}