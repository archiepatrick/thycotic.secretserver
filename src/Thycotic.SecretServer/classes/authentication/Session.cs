﻿using System;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Management.Automation;
using System.Management.Automation.Runspaces;
using Newtonsoft.Json;
using RestSharp;

namespace Thycotic.PowerShell.Authentication
{
    public class Session
    {
        public string SecretServer { get; set; }
        public string SecretServerVersion { get; set; }
        public string ApiVersion { get; set; } = "api/v1";
        public string WindowsAuth { get; } = "winauthwebservices";
        public string ApiUrl { get; set; }
        public string AccessToken { get; set; }
        public string RefreshToken { get; set; }
        public string TokenType { get; set; }
        public int ExpiresIn { get; set; }
        public DateTime StartTime { get; set; }
        public DateTime TimeOfDeath { get; set; }
        public int Take { get; set; } = int.MaxValue;

        public bool IsValidSession()
        {
            // check if string is null or empty
            if (string.IsNullOrEmpty(this.AccessToken) & this.StartTime == default(DateTime))
            {
                return false;
            }
            // check if tokentype equals SdkClient or WindowsAuth
            else if (this.TokenType.Equals("WindowsAuth") || this.TokenType.Equals("SdkClient"))
            {
                return true;
            }
            // otherwise assume it is good
            else
            {
                return true;
            }
        }

        public bool IsValidToken()
        {
            // check if AccessToken is empty or null
            if (string.IsNullOrEmpty(this.AccessToken))
            {
                return false;
            }
            else if (DateTime.Now < this.TimeOfDeath && (!this.TokenType.Equals("ExternalToken") || !this.TokenType.Equals("SdkClient")))
            {
                return true;
            }
            else if (DateTime.Now > this.TimeOfDeath && (!this.TokenType.Equals("ExternalToken") || !this.TokenType.Equals("SdkClient")))
            {
                return false;
            }
            else if (this.TokenType.Equals("ExternalToken") || this.TokenType.Equals("WindowsAuth") || this.TokenType.Equals("SdkClient"))
            {
                // no way to validate these token types, assume to be good
                return true;
            }
            else
            {
                return true;
            }
        }

        public bool CheckTokenTtl(int Value)
        {
            //timespan of current time to TimeOfDeath
            TimeSpan ttl = this.TimeOfDeath - DateTime.Now;

            //check if ttl in minutes is less than or equal Value
            if (ttl.TotalMinutes <= Value)
            {
                return true;
            }
            else
            {
                return false;
            }
        }

        public bool SessionExpire()
        {
            if (!this.TokenType.Equals("WindowsAuth") || !this.TokenType.Equals("SdkClient"))
            {
                try
                {
                    var sessionClient = new RestClient(this.ApiUrl + "/oauth-expiration");
                    var sessionRequest = new RestRequest(Method.POST);
                    sessionRequest.AddHeader("Authorization", "Bearer " + this.AccessToken);
                    IRestResponse sessionResponse = sessionClient.Execute(sessionRequest);
                    return true;
                }
                catch
                {
                    return false;
                }
            }
            else
            {
                return false;
            }
        }
    }
}