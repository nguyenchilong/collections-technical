function setCookie(cookieName, cookieValue, expiredDays, attributes) {
  const d = new Date();
  d.setTime(d.getTime() + (expiredDays * 24 * 60 * 60 * 1000));
  const expires = "expires="+d.toUTCString();
  document.cookie = cookieName + "=" + cookieValue + ";" + expires + ";path=/" + (typeof attributes !== undefined ? (";" + attributes) : "");
}

function getCookie(cookieName) {
  const name = cookieName + "=";
  const cookiesObject = document.cookie.split(';');
  for (let i = 0; i < cookiesObject.length; i++) {
    let cookie = cookiesObject[i];
    while (cookie.charAt(0) === ' ') {
      cookie = cookie.substring(1);
    }
    if (cookie.indexOf(name) === 0) {
      return cookie.substring(name.length, cookie.length);
    }
  }
  return "";
}

/**
 * just test get & set cookie with name is "username"
 */
function checkCookie() {
  let user = getCookie("username");
  if (user !== "") {
    alert("Welcome again " + user);
  } else {
    user = prompt("Please enter your name:", "");
    if (user !== "" && user != null) {
      setCookie("username", user, 365);
    }
  }
}



/**
 *
 * apply cookie for all sub-domain
 * when set cookie then add more attribute [domain=domain_name]
 * domain_name with
 *  - domain.com: only this domain can access & sub-domain can't access cookie
 *  - .domain.com: all sub-domain can access cookie
 *  - example: "Set-Cookie: name=value; domain=example.com" OR "Set-Cookie: name=value; domain=.example.com"
 *
 *
 *
 *
 *
 * Be careful if you are working on localhost! If you store your cookie in JavaScript like this:
 * document.cookie = "key=value;domain=localhost"
 * It might not be accessible to your subdomain, like sub.localhost. In order to solve this issue you need to use VirtualHost. For example, you can configure your virtual host with ServerName localhost.com, and then you will be able to store your cookie on your domain and subdomain like this:
 * document.cookie = "key=value;domain=localhost.com"
 *
 */
setCookie('token', 'token_value_from_login_api', 1, 'domain=.domain_name.com');
const cookieValue = getCookie('token');
// console.log(cookieValue) = token_value_from_login_api
