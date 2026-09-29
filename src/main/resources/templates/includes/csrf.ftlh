<#-- Token CSRF exigido pelo Spring Security em todo formulário POST -->
<#if _csrf??><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"></#if>
