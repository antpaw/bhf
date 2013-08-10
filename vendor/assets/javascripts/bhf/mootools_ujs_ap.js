/*
---
description: A MooTools driver for the Ruby on Rails 3 unobtrusive JavaScript API.

license: MIT-style

authors:
- Kevin Valdek
- Oskar Krawczyk

requires:
  core/1.4: '*'

provides:
  - Rails 3 MooTools driver

...
*/

window.addEvent('domready', function(){
  
  rails.csrf = {
    token: rails.getCsrf('token'),
    param: rails.getCsrf('param')
  };
  
  rails.applyEvents();
});

(function($){
  
  window.rails = {
    /**
     * If el is passed as argument, events will only be applied to
     * elements within el. Otherwise applied to document body.
     */
    applyEvents: function(el){
      el = $(el || document.body);
      var apply = function(selector, action, callback){
        el.addEvent(action + ':relay(' + selector + ')', callback);
      };
      
      apply('form[data-remote="true"]', 'submit', rails.handleRemote);
      apply('a[data-remote="true"], input[data-remote="true"]', 'click', rails.handleRemote);
      apply('a[data-method][data-remote!=true]', 'click', function(event){
        event.preventDefault();
        if (rails.confirmed(this)){
          var form = Element('form', {
            method: 'post',
            action: this.get('href'),
            styles: {
              display: 'none'
            }
          }).inject(this, 'after');
          
          var methodInput = Element('input', {
            type: 'hidden',
            name: '_method',
            value: this.get('data-method')
          });
          
          var csrfInput = Element('input', {
            type: 'hidden',
            name: rails.csrf.param,
            value: rails.csrf.token
          });
          
          form.adopt(methodInput, csrfInput).submit();
        }
      });
      var noMethodNorRemoteConfirm = ':not([data-method]):not([data-remote=true])[data-confirm]';
      apply('a' + noMethodNorRemoteConfirm + ',' + 'input' + noMethodNorRemoteConfirm, 'click', function(){
        return rails.confirmed(this);
      });
    },
    
    getCsrf: function(name){
      var meta = document.getElement('meta[name=csrf-' + name + ']');
      return (meta ? meta.get('content') : null);
    },
    
    confirmed: function(el){
      var confirmMessage = el.get('data-confirm');
      if(confirmMessage && !confirm(confirmMessage)){
        return false;
      }
      return true;
    },
    
    disable: function(el){
      var button = el.get('data-disable-with') ? el : el.getElement('[data-disable-with]');
      if (button){
        var enableWith = button.get('value');
        el.addEvent('ajax:complete', function(){
          button.set({
            value: enableWith,
            disabled: false
          });
        });
        button.set({
          value: button.get('data-disable-with'),
          disabled: true
        });
      }
    },
    
    handleRemote: function(event){
      event.preventDefault();
      if(rails.confirmed(this)){
        this.request = new Request.Rails(this);
        rails.disable(this);
        this.request.send();
      }
    }
  };
  
  Request.Rails = new Class({
  
    Extends: Request,
    
    initialize: function(element, options){
      this.el = element;
      this.parent(Object.merge({
        method: this.el.get('method') || this.el.get('data-method') || 'get',
        url: this.el.get('action') || this.el.get('href')
      }, options));
      this.addRailsEvents();
    },
    
    send: function(options) {
      this.el.fireEvent('ajax:before');
      if (this.el.get('tag') === 'form'){
        this.options.data = this.el;
      }
      this.parent(options);
      this.el.fireEvent('ajax:after', this.xhr);
    },
    
    addRailsEvents: function(){
      this.addEvent('request', function(){
        this.el.fireEvent('ajax:loading', this.xhr);
      });
      
      this.addEvent('success', function(){
        this.el.fireEvent('ajax:success', this.xhr);
      });
      
      this.addEvent('complete', function(){
        this.el.fireEvent('ajax:complete', this.xhr);
        this.el.fireEvent('ajax:loaded', this.xhr);
      });
      
      this.addEvent('failure', function(){
        this.el.fireEvent('ajax:failure', this.xhr);
      });
    }
    
  });
  
})(document.id);
